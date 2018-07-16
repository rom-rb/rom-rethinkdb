require 'rom/commands'
require 'rom/commands/create'

module ROM
  module RethinkDB
    module Commands
      class Create < ROM::Commands::Create
        adapter :rethinkdb

        def execute(tuples)
          insert_tuples =  [tuples].flatten.map do |tuple|
            attributes = input[tuple]
            attributes.to_h
          end

          insert(insert_tuples)
        end

        def insert(tuples)
          pks = dataset.insert(tuples).fetch("generated_keys")

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
