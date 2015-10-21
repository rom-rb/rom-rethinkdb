require 'rom/commands'
require 'rom/commands/delete'

module ROM
  module RethinkDB
    module Commands
      class Delete < ROM::Commands::Delete
        adapter :rethinkdb

        def execute
          deleted = dataset.to_a
          dataset.delete
          deleted
        end

        def dataset
          relation.dataset
        end
      end
    end
  end
end
