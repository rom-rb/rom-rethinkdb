require 'rom/rethinkdb/dataset'

module ROM
  module RethinkDB
    class Repository < ROM::Repository
      # RethinkDB repository interface
      #
      # @overload connect(options)
      #   Connects to database passing options
      #
      #   @param [Hash] options connection options
      #
      # @example
      #   repository = ROM::RethinkDB::Repository.new({ host: 'localhost',
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
        rql.db(options[:db]).table(name.to_s).run(connection)
        datasets[name] = Dataset.new(name, rql, connection)
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
        rql.db(options[:db]).table(name.to_s).run(connection)
        true
      rescue ::RethinkDB::RqlRuntimeError
        false
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
