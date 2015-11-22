require 'rom/rethinkdb/dataset'
require 'rom/rethinkdb/commands'
require 'connection_pool'
require 'thread'

module ROM
  module RethinkDB
    class DatasetCache
      def initialize
        @mutex = Mutex.new
        @datasets = {}
      end

      def fetch(name)
        @mutex.synchronize{ @datasets.fetch(name.to_s) { |k| @datasets[k] = yield(k) } }
      end
    end
    class Gateway < ROM::Gateway
      # RethinkDB gateway interface
      #
      # @overload connect(options)
      #   Connects to database passing options
      #
      #   @param [Hash] options connection options
      #
      # @example
      #   gateway = ROM::RethinkDB::Gateway.new({ host: 'localhost',
      #     port: 28015, db: 'database' })
      #
      # @api public
      def initialize(options)
        @datasets = DatasetCache.new
        @options = options
        @rql = ::RethinkDB::RQL.new
        pool_size = options.fetch(:pool_size, 5).to_i
        options.freeze
        @connections = ConnectionPool.new(size: pool_size) { rql.connect(options).auto_reconnect(true) }
      end

      # Return dataset with the given name
      #
      # @param [String] name a dataset name
      #
      # @return [Dataset]
      #
      # @api public
      def dataset(name)
        @datasets.fetch(name) { |n| Dataset.new(rql.table(n), rql, self) }
      end

      alias :[] :dataset

      # Runs the ReQL query and returns the data.
      #
      # @param [RethinkDB::RQL]  query a RQL query
      #
      # @api private
      def run(query)
        @connections.with { |c| query.run(c) }
      end

      # Check if dataset exists
      #
      # @param [String] name dataset name
      #
      # @api public
      def dataset?(name)
        run rql.db(options[:db]).table_list.contains(name.to_s)
      end

      # Disconnect from database
      #
      # @api public
      def disconnect
        @connections.shutdown(&:close)
        self
      end

      private

      # @api private
      attr_reader :options, :rql
    end
  end
end
