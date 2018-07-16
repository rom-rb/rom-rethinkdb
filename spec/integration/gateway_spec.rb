require 'spec_helper'

describe 'RethinkDB gateway' do
  include PrepareDB

  include_context 'db setup'

  before do
    create_table('test_db', 'users') unless table_exist?('test_db', 'users')

    configuration.relation(:users) do
      auto_struct true

      schema do
        attribute :id, ROM::Types::String
        attribute :name, ROM::Types::String
        attribute :street, ROM::Types::String
      end

      def with_name(name)
        filter(name: name)
      end

      def only_john_and_jane
        filter { |user| rql.expr(%w(John Jane)).contains(user["name"]) }
      end

      def only_names
        pluck(:name)
      end

      def by_name
        order_by(:name)
      end

      def names_on_street(street)
        filter(street: street).order_by(:name).pluck(:name)
      end
    end

    # fill table
    insert_data('test_db', 'users', [
                             { name: 'John', street: 'Main Street' },
                             { name: 'Joe', street: '2nd Street' },
                             { name: 'Jane', street: 'Main Street' }
                         ])
  end

  after do
    truncate_table('test_db', 'users')
  end

  describe 'env#relation' do
    it 'returns mapped object' do
      jane = container.relations[:users].with_name('Jane').first

      expect(jane.name).to eql('Jane')
    end

    it 'returns John and Jane objects' do
      users = container.relations[:users].only_john_and_jane.to_a

      expect(users.count).to eql(2)
      expect(users.map(&:name).sort).to eql(%w(Jane John))
    end

    it 'returns specified fields' do
      user = container.relations[:users].only_names.to_a.first

      expect(user.to_hash).to match(name: kind_of(String))
    end

    it 'returns ordered data' do
      results = container.relations[:users].by_name.to_a

      expect(results[0].name).to eql('Jane')
      expect(results[1].name).to eql('Joe')
      expect(results[2].name).to eql('John')
    end

    it 'returns data with combined conditions' do
      results = container.relations[:users].names_on_street('Main Street').to_a

      expect(results[0].name).to eql('Jane')
      expect(results[1].name).to eql('John')
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
