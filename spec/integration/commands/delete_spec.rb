require 'spec_helper'

describe 'Commands / Delete' do
  include_context 'db setup'

  let(:users) { container.commands[:users] }

  before do
    create_table('test_db', 'users') unless table_exist?('test_db', 'users')

    configuration.relation(:users) do
      def by_id(id)
        filter(id: id)
      end
    end

    configuration.commands(:users) do
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
    element = container.relations[:users].to_a.first

    result = users.delete.by_id(element[:id]).call
    result.delete(:id)

    expect(result).to eql(name: 'John', street: 'Main Street')

    result = container.relations[:users].to_a
    expect(result.count).to eql(0)
  end
end
