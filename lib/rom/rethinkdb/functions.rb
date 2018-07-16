require 'transproc'

module ROM
  module RethinkDB
    module Functions
      extend Transproc::Registry

      import Transproc::ArrayTransformations
      import Transproc::HashTransformations

      def self.symbolize_hashes(input)
        self[:map_array, self[:symbolize_keys]].(input)
      end
    end
  end
end
