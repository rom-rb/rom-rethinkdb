require 'spec_helper'
require 'virtus'

describe 'Commands / Updates' do
  include_context 'db setup'

  let(:users) { container.commands[:users] }

  before do
    create_table('test_db', 'users') unless table_exist?('test_db', 'users')

    configuration.relation(:users) do
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

    configuration.mappers do
      define(:users) do
        model User
        register_as :entity
      end
    end

    configuration.commands(:users) do
      define(:update)
    end

    # fill table
    insert_data('test_db', 'users' , { name: 'John', street: 'Main Street' })
  end

  after do
    truncate_table('test_db', 'users')
  end

  it 'updates everything when there is no original tuple' do
    element = container.relation(:users).as(:entity).to_a.first
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
