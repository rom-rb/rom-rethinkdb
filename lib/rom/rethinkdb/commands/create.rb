require 'rom/commands'
require 'rom/commands/create'

module ROM
  module RethinkDB
    module Commands
      class Create < ROM::Commands::Create
        def execute(tuples)
          insert_tuples =  [tuples].flatten.map do |tuple|
            attributes = input[tuple]
            validator.call(attributes)
            attributes.to_h
          end

          insert(insert_tuples)
        end

        def insert(tuples)
          pks = dataset.scope.insert(tuples)
                .run(dataset.connection)["generated_keys"]

          dataset.filter { |user| relation.rql.expr(pks).contains(user["id"]) }
            .to_a
        end

        def dataset
          relation.dataset
        end
      end
    end
  end
end
