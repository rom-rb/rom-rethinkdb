require 'spec_helper'

describe 'Commands / Create' do
  include_context 'db setup'

  let(:users) { container.commands[:users] }

  before do
    create_table('test_db', 'users') unless table_exist?('test_db', 'users')

    configuration.relation(:users) do
      schema do
        attribute :id, ROM::Types::Integer
        attribute :name, ROM::Types::String
        attribute :street, ROM::Types::String
      end
    end

    configuration.commands(:users) do
      define(:create) do
        result :one
      end

      define(:create_many, type: :create) do
        result :many
      end
    end
  end

  after do
    truncate_table('test_db', 'users')
  end

  it 'returns a single tuple when result is set to :one' do
    result = users.create.call('name' => 'John', 'street' => 'Main Street')
    result.delete(:id)
    expect(result).to eql(name: 'John', street: 'Main Street')

    result = container.relations[:users].to_a
    expect(result.count).to eql(1)
  end

  it 'returns tuples when result is set to :many' do
    result = users.create_many.call([
      { 'name' => 'Jane', 'street' => 'Main Street' },
      { 'name' => 'Jack', 'street' => 'Main Street' }
    ])
    result.each_with_index { |_, index| result[index].delete(:id) }

    expect(result).to match_array([
      { name: 'Jane', street: 'Main Street' },
      { name: 'Jack', street: 'Main Street' }
    ])

    result = container.relations[:users].to_a
    expect(result.count).to eql(2)
  end
end
