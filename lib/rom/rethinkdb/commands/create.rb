require 'rom/commands'
require 'rom/commands/create'

module ROM
  module RethinkDB
    module Commands
      class Create < ROM::Commands::Create
        adapter :rethinkdb

        def execute(tuples)
          insert_tuples = [tuples].flatten.map do |tuple|
            attributes = input[tuple]
            validator.call(attributes)
            attributes.to_h
          end

          pks = insert(insert_tuples)
          get_by_pks(pks)
        end

        def insert(tuples)
          dataset.scope.insert(tuples)
            .run(dataset.connection)
            .fetch('generated_keys')
        end

        def get_by_pks(pks)
          dataset.filter do |user|
            relation.rql.expr(pks).contains(user['id'])
          end.to_a
        end

        def dataset
          relation.dataset
        end
      end
    end
  end
end
