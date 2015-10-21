require 'spec_helper'

describe 'Commands / Delete' do
  subject(:rom) { setup.finalize }

  # If :rethinkdb is not passed in the gateway is named `:default`
  let(:setup) { ROM.setup(:rethinkdb, db_options.merge(db: 'test_db')) }

  subject(:users) { rom.commands.users }
  let(:gateway) { rom.gateways[:default] }

  before do
    create_table('test_db', 'users') unless table_exist?('test_db', 'users')

    setup.relation(:users) do
      def by_id(id)
        filter(id: id)
      end
    end

    setup.commands(:users) do
      define(:delete) do
        result :one
      end
    end

    # fill table
    insert_data('test_db', 'users', { name: 'John', street: 'Main Street' })
  end

  after do
    truncate_table('test_db', 'users')
  end

  it 'deletes all tuples in a restricted relation' do
    element = rom.relation(:users).to_a.first

    result = users.try { users.delete.by_id(element['id']).call }
    result = result.value
    result.delete('id')

    expect(result).to eql('name' => 'John', 'street' => 'Main Street')

    result = rom.relation(:users).to_a
    expect(result.count).to eql(0)
  end
end
