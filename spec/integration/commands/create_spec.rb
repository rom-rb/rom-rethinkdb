require 'spec_helper'
require 'virtus'

describe 'Commands / Create' do
  subject(:rom) { setup.finalize }

  # If :rethinkdb is not passed in the gateway is named `:default`
  let(:setup) { ROM.setup(:rethinkdb, db_options.merge(db: 'test_db')) }

  subject(:users) { rom.commands.users }

  before do
    create_table('test_db', 'users')

    setup.relation(:users)

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
      define(:create) do
        result :one
      end

      define(:create_many, type: :create) do
        result :many
      end
    end
  end

  after do
    drop_table('test_db', 'users')
  end

  it 'returns a single tuple when result is set to :one' do
    result = users.try do
      users.create.call('name' => 'John', 'street' => 'Main Street')
    end
    result = result.value
    result.delete("id")
    expect(result).to eql('name' => 'John', 'street' => 'Main Street')

    result = rom.relation(:users).as(:entity).to_a
    expect(result.count).to eql(1)
  end

  it 'returns tuples when result is set to :many' do
    result = users.try do
      users.create_many.call([
        { 'name' => 'Jane', 'street' => 'Main Street' },
        { 'name' => 'Jack', 'street' => 'Main Street' }
      ])
    end
    result = result.value.to_a
    result.each_with_index { |_, index| result[index].delete('id') }

    expect(result).to match_array([
      { 'name' => 'Jane', 'street' => 'Main Street' },
      { 'name' => 'Jack', 'street' => 'Main Street' }
    ])

    result = rom.relation(:users).as(:entity).to_a
    expect(result.count).to eql(2)
  end
end
