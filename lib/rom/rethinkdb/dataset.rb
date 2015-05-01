module ROM
  module RethinkDB
    # Dataset for RethinkDB
    #
    # @api public
    class Dataset
      attr_reader :name, :rql, :connection

      def initialize(name, rql, connection)
        @name = name.to_s
        @rql = rql
        @connection = connection
      end

      def each(&block)
        with_set { |set| set.each(&block) }
      end

      def where(query)
        rql.table(name).filter(query).run(connection)
      end

      def pluck(*selectors)
        rql.table(name).pluck(selectors).run(connection)
      end

      def order(condition)
        rql.table(name).order_by(condition).run(connection)
      end

      private

      def with_set
        yield(query)
      end
    end
  end
end
