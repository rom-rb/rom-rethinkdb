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
        wrap_array(scope.run(connection))
      end

      def each(&block)
        to_a.each(&block)
      end

      def method_missing(command, *args, &block)
        self.class.new(scope.public_send(command, *args, &block),
          rql, connection)
      end

      private

      def wrap_array(object)
        return [object] if object.is_a?(Hash)
        return object if object.is_a?(Array)
        return [] if object.nil?

        object.to_a
      end
    end
  end
end
