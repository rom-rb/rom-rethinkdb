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
      def rql
        dataset.rql
      end

      def count
        dataset.count
      end

      def filter(*args, &block)
        __new__(dataset.__send__(__method__, *args, &block))
      end

      def pluck(*args, &block)
        __new__(dataset.__send__(__method__, *args, &block))
      end

      def order_by(*args, &block)
        __new__(dataset.__send__(__method__, *args, &block))
      end
    end
  end
end
