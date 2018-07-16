require_relative 'functions'

module ROM
  module RethinkDB
    # Dataset for RethinkDB
    #
    # @api public
    class Dataset
      extend Forwardable
      include Enumerable

      attr_reader :scope, :rql, :gateway

      def initialize(scope, rql, gateway)
        @scope = scope
        @rql = rql
        @gateway = gateway
      end

      def to_a
        Functions.symbolize_hashes(Array(gateway.run(scope).to_a))
      end

      def_instance_delegators :to_a, :each, :first, :last

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

      %i[filter pluck order_by].each do |method_name|
        define_method(method_name) do |*args, &block|
          self.class.new(scope.send(method_name, *args, &block), rql,
          gateway)
        end
      end
    end
  end
end
