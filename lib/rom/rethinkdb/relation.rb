module ROM
  module RethinkDB
    # Relation subclass of RethinkDB adapter
    #
    # @example
    #   class Users < ROM::Relation[:rethinkdb]
    #   end
    #
    # @api public
    class Relation < ROM::Relation
      forward :where, :pluck, :order
    end
  end
end
