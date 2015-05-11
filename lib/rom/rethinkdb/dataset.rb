module ROM
  module RethinkDB
    # Dataset for RethinkDB
    #
    # @api public
    class Dataset
      attr_reader :scope, :connection

      def initialize(scope, connection)
        @scope = scope
        @connection = connection
      end

      def each(&block)
        with_set { |set| set.each(&block) }
      end

      def where(query)
        scope.filter(query).run(connection)
      end

      def pluck(*selectors)
        scope.pluck(selectors).run(connection)
      end

      def order(condition)
        scope.order_by(condition).run(connection)
      end

      private

      def with_set
        yield(query)
      end
    end
  end
end
