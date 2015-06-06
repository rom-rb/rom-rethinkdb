require 'rom/commands'
require 'rom/commands/delete'

module ROM
  module RethinkDB
    module Commands
      class Delete < ROM::Commands::Delete
        def execute
          deleted = dataset.to_a
          dataset.scope.delete.run(dataset.connection)
          deleted
        end

        def dataset
          relation.dataset
        end
      end
    end
  end
end
