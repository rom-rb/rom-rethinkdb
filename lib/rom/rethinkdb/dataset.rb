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
        scope.run(connection).each(&block)
      end

      [:filter, :pluck, :order_by].each do |method_name|
        define_method(method_name) do |*args|
          self.class.new(scope.send(method_name, *args), connection)
        end
      end
    end
  end
end
