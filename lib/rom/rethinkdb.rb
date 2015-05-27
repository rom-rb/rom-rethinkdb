require 'rethinkdb'

require 'rom'
require 'rom/rethinkdb/version'
require 'rom/rethinkdb/relation'
require 'rom/rethinkdb/gateway'

ROM.register_adapter(:rethinkdb, ROM::RethinkDB)
