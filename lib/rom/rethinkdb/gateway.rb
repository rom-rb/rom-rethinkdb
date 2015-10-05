require 'rom/rethinkdb/dataset'
require 'rom/rethinkdb/commands'

module ROM
  module RethinkDB
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
        @datasets = {}
        @options = options
        @rql = ::RethinkDB::RQL.new
        @connection = rql.connect(options)
      end

      # Return dataset with the given name
      #
      # @param [String] name a dataset name
      #
      # @return [Dataset]
      #
      # @api public
      def dataset(name)
        datasets[name] = Dataset.new(rql.table(name.to_s), rql, connection)
      end

      # Return dataset with the given name
      #
      # @param [String] name dataset name
      #
      # @return [Dataset]
      #
      # @api public
      def [](name)
        datasets[name.to_s]
      end

      # Check if dataset exists
      #
      # @param [String] name dataset name
      #
      # @api public
      def dataset?(name)
        rql.db(options[:db]).table_list.run(connection).include?(name.to_s)
      end

      # Disconnect from database
      #
      # @api public
      def disconnect
        connection.close
      end

      private

      # @api private
      attr_reader :datasets, :options, :rql
    end
  end
end
