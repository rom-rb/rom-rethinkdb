require 'rom/commands'
require 'rom/commands/update'

module ROM
  module RethinkDB
    module Commands
      class Update < ROM::Commands::Update
        def execute(tuple)
          attributes = input[tuple]
          validator.call(attributes)
          tuple = attributes.to_h

          update(tuple)
        end

        def update(tuple)
          dataset.scope.update(tuple).run(dataset.connection)
          dataset.to_a
        end

        def dataset
          relation.dataset
        end
      end
    end
  end
end
