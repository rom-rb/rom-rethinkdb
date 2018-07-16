require 'rom/commands'
require 'rom/commands/delete'

module ROM
  module RethinkDB
    module Commands
      class Delete < ROM::Commands::Delete
        adapter :rethinkdb

        def execute
          deleted = relation.to_a
          source.dataset.delete
          deleted
        end
      end
    end
  end
end
