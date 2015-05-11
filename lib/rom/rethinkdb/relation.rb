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
      def filter(*args)
        __new__(dataset.__send__(__method__, *args))
      end

      def pluck(*args)
        __new__(dataset.__send__(__method__, *args))
      end

      def order_by(*args)
        __new__(dataset.__send__(__method__, *args))
      end
    end
  end
end
