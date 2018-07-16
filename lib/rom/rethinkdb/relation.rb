module ROM
  module RethinkDB
    # Relation subclass of RethinkDB adapter
    #
    # @example
    #   class Users < ROM::Relation[:rethinkdb]
    #   end
    #
    # @api public
    class Relation < ROM::Relation
      extend Forwardable

      adapter :rethinkdb

      forward :filter, :pluck, :order_by

      def_instance_delegators :dataset, :rql, :count

      def pluck(*names)
        new(dataset.pluck(*names), schema: schema.project(*names))
      end
    end
  end
end
