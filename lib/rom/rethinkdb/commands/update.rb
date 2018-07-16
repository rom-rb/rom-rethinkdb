require 'rom/commands'
require 'rom/commands/update'

module ROM
  module RethinkDB
    module Commands
      class Update < ROM::Commands::Update
        adapter :rethinkdb

        def execute(tuple)
          tuple = input[tuple].to_h

          update(tuple)
        end

        def update(tuple)
          dataset.update(tuple)
          dataset.to_a
        end

        def dataset
          relation.dataset
        end
      end
    end
  end
end
