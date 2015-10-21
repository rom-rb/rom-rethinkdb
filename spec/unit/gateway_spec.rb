require 'spec_helper'

require 'rom/lint/spec'

describe ROM::RethinkDB::Gateway do
  let(:gateway) { ROM::RethinkDB::Gateway }
  let(:uri) { { host: 'localhost', port: '28015', db: 'database' } }

  it_behaves_like "a rom gateway" do
    let(:identifier) { :rethinkdb }
  end

  describe '.new' do
    context 'default values' do
      let(:connection) { gateway.new(uri).connection }

      class FakeQuery
        def initialize(&block)
          @block = block
        end

        def run(connection)
          @block.call(connection)
        end
      end

      it 'returns them' do
        connection_yielded = false
        query = FakeQuery.new{|connection|
          expect(connection.default_db).to eql('database')
          expect(connection.host).to eql('localhost')
          expect(connection.port).to eql(28_015)
          connection_yielded = true
        }

        gateway.new(uri).run(query)

        expect(connection_yielded).to eq(true)
      end
    end
  end
end
