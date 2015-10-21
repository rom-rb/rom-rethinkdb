module ROM
  module RethinkDB
    # Dataset for RethinkDB
    #
    # @api public
    class Dataset
      attr_reader :scope, :rql, :gateway

      def initialize(scope, rql, gateway)
        @scope = scope
        @rql = rql
        @gateway = gateway
      end

      def to_a
        gateway.run(scope).to_a
      end

      def each(&block)
        to_a.each(&block)
      end

      def insert(tuples)
        gateway.run(scope.insert(tuples))
      end

      def delete
        gateway.run(scope.delete)
      end

      def update(reql)
        gateway.run(scope.update(reql))
      end

      def count
        gateway.run(scope.count)
      end

      [:filter, :pluck, :order_by].each do |method_name|
        define_method(method_name) do |*args, &block|
          self.class.new(scope.send(method_name, *args, &block), rql,
          gateway)
        end
      end
    end
  end
end
