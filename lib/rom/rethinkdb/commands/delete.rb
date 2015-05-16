require 'rom/commands'
require 'rom/commands/delete'

module ROM
  module RethinkDB
    module Commands
      class Delete < ROM::Commands::Delete
        def execute
          deleted = target.to_a
          dataset.scope.delete.run(dataset.connection)
          deleted
        end

        def dataset
          target.dataset
        end
      end
    end
  end
end
