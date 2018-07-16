require 'rom/rethinkdb/dataset'
require 'rom/rethinkdb/commands'
require 'connection_pool'
require 'thread'
require 'dry/core/cache'

module ROM
  module RethinkDB
    class Gateway < ROM::Gateway
      extend Dry::Core::Cache
      adapter :rethinkdb

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
        fetch_or_store(name) { Dataset.new(rql.table(name), rql, self) }
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
