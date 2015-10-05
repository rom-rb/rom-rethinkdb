require 'spec_helper'
require 'virtus'

describe 'Commands / Updates' do
  subject(:rom) { setup.finalize }

  # If :rethinkdb is not passed in the gateway is named `:default`
  let(:setup) { ROM.setup(:rethinkdb, db_options.merge(db: 'test_db')) }

  subject(:users) { rom.commands.users }
  let(:gateway) { rom.gateways[:default] }

  before do
    clean_table('test_db', 'users')

    setup.relation(:users) do
      def by_id(id)
        filter(id: id)
      end
    end

    class User
      include Virtus.model

      attribute :id, Integer
      attribute :name, String
      attribute :street, String
    end

    setup.mappers do
      define(:users) do
        model User
        register_as :entity
      end
    end

    setup.commands(:users) do
      define(:update)
    end

    # fill table
    [
      { name: 'John', street: 'Main Street' }
    ].each do |data|
      gateway.send(:rql).table('users').insert(data)
        .run(gateway.connection)
    end
  end

  after do
    clean_table('test_db', 'users')
  end

  it 'updates everything when there is no original tuple' do
    element = rom.relation(:users).as(:entity).to_a.first
    expect(element.name).to eql('John')
    expect(element.street).to eql('Main Street')

    result = users.try do
      users.update.by_id(element.id).call(street: '2nd Street')
    end
    result = result.value.to_a
    result.each_with_index { |_, index| result[index].delete('id') }

    expect(result)
      .to match_array([{ 'name' => 'John', 'street' => '2nd Street' }])
  end
end
