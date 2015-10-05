require 'spec_helper'
require 'virtus'

describe 'RethinkDB gateway' do
  let(:gateway) { rom.gateways[:default] }
  let(:setup) { ROM.setup(:rethinkdb, db_options.merge(db: 'test_db')) }
  subject(:rom) { setup.finalize }

  before do
    clean_table('test_db', 'users')

    setup.relation(:users) do
      def by_id(id)
        get(id)
      end

      def with_name(name)
        filter(name: name)
      end

      def only_john_and_jane
        filter { |user| rql.expr(%w(John Jane)).contains(user["name"]) }
      end

      def only_names
        pluck('name')
      end

      def by_name
        order_by('name')
      end

      def names_on_street(street)
        filter(street: street).order_by('name').pluck(:name)
      end

      def undefined
        undfn(with: 'args')
      end
    end

    class User
      include Virtus.value_object

      values do
        attribute :id, Integer
        attribute :name, String
        attribute :street, String
      end
    end

    setup.mappers do
      define(:users) do
        model(User)
        register_as(:entity)
      end
    end

    # fill table
    [
      { name: 'John', street: 'Main Street' },
      { name: 'Joe', street: '2nd Street' },
      { name: 'Jane', street: 'Main Street' }
    ].each do |data|
      gateway.send(:rql).table('users').insert(data)
        .run(gateway.connection)
    end
  end

  after do
    clean_table('test_db', 'users')
  end

  describe 'env#relation' do
    it 'raise error on undefined method' do
      expect {
        rom.relation(:users).undefined.to_a
      }.to raise_error(NoMethodError)
    end

    it 'return data by primary key' do
      pk = rom.relation(:users).to_a.map { |o| o.fetch('id') }.first
      user = rom.relation(:users).as(:entity).by_id(pk).one

      expect(user.id).to eq(pk)
    end

    it 'returns mapped object' do
      jane = rom.relation(:users).as(:entity).with_name('Jane').to_a.first

      expect(jane.name).to eql('Jane')
    end

    it 'returns John and Jane objects' do
      users = rom.relation(:users).as(:entity).only_john_and_jane.to_a

      expect(users.count).to eql(2)
      expect(users.map(&:name).sort).to eql(%w(Jane John))
    end

    it 'returns specified fields' do
      user = rom.relation(:users).as(:entity).only_names.to_a.first

      expect(user.id).to be_nil
      expect(user.name).not_to be_nil
      expect(user.street).to be_nil
    end

    it 'returns ordered data' do
      results = rom.relation(:users).as(:entity).by_name.to_a

      expect(results[0].name).to eql('Jane')
      expect(results[1].name).to eql('Joe')
      expect(results[2].name).to eql('John')
    end

    it 'returns data with combined conditions' do
      results = rom.relation(:users).as(:entity).names_on_street('Main Street')
                .to_a

      expect(results[0].id).to be_nil
      expect(results[0].name).to eql('Jane')
      expect(results[0].street).to be_nil

      expect(results[1].id).to be_nil
      expect(results[1].name).to eql('John')
      expect(results[1].street).to be_nil
    end
  end

  describe 'gateway#dataset?' do
    it 'returns true if a collection exists' do
      expect(gateway.dataset?(:users)).to be(true)
    end

    it 'returns false if a does not collection exist' do
      expect(gateway.dataset?(:not_here)).to be(false)
    end
  end
end
