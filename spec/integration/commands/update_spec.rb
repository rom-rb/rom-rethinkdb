require 'spec_helper'

describe 'Commands / Updates' do
  include_context 'db setup'

  let(:users) { container.commands[:users] }

  before do
    create_table('test_db', 'users') unless table_exist?('test_db', 'users')

    configuration.relation(:users) do
      auto_struct true

      schema do
        attribute :id, ROM::Types::Integer
        attribute :name, ROM::Types::String
        attribute :street, ROM::Types::String
      end

      def by_id(id)
        filter(id: id)
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
    element = container.relations[:users].to_a.first
    expect(element.name).to eql('John')
    expect(element.street).to eql('Main Street')

    result = users.update.by_id(element.id).call(street: '2nd Street')
    result.each_with_index { |_, index| result[index].delete(:id) }

    expect(result)
      .to match_array([{ name: 'John', street: '2nd Street' }])
  end
end
