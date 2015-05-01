require 'spec_helper'

require 'rom/lint/spec'

describe ROM::RethinkDB::Repository do
  let(:repository) { ROM::RethinkDB::Repository }
  let(:uri) { { host: 'localhost', port: '28015', db: 'database' } }

  it_behaves_like "a rom repository" do
    let(:identifier) { :rethinkdb }
  end

  describe '.new' do
    context 'default values' do
      let(:connection) { repository.new(uri).connection }

      it 'returns them' do
        expect(connection.default_db).to eql('database')
        expect(connection.host).to eql('localhost')
        expect(connection.port).to eql(28_015)
      end
    end
  end
end
