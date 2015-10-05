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
      adapter :rethinkdb

      def rql
        dataset.rql
      end

      def count
        dataset.to_a.count
      end

      def method_missing(command, *args, &block)
        __new__(dataset.public_send(command, *args, &block))
      end
    end
  end
end
