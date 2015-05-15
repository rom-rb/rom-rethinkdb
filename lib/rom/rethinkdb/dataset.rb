module ROM
  module RethinkDB
    # Dataset for RethinkDB
    #
    # @api public
    class Dataset
      attr_reader :scope, :rql, :connection

      def initialize(scope, rql, connection)
        @scope = scope
        @rql = rql
        @connection = connection
      end

      def to_a
        scope.run(connection)
      end

      def each(&block)
        to_a.each(&block)
      end

      [:filter, :pluck, :order_by].each do |method_name|
        define_method(method_name) do |*args, &block|
          self.class.new(scope.send(method_name, *args, &block), rql,
          connection)
        end
      end
    end
  end
end
