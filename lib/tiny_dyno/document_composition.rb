require 'tiny_dyno/attributes'
require 'tiny_dyno/changeable'
require 'tiny_dyno/fields'
require 'tiny_dyno/stateful'
require 'tiny_dyno/tables'
require 'tiny_dyno/hash_keys'
require 'tiny_dyno/persistable'

module TinyDyno
  module DocumentComposition
    extend ActiveSupport::Concern

    include Attributes
    include Changeable
    include Fields
    include HashKeys
    include Persistable
    include Stateful
    include Tables


    MODULES = [
        Attributes,
        Changeable,
        Fields,
        HashKeys,
        Persistable,
        Stateful,
        Tables,
    ]

    class << self

      # Get a list of methods that would be a bad idea to define as field names
      # or override when including TinyDyno::Document.
      #
      # @example Bad thing!
      #   TinyDyno::Components.prohibited_methods
      #
      # @return [ Array<Symbol> ]
      def prohibited_methods
        @prohibited_methods ||= MODULES.flat_map do |mod|
          mod.instance_methods.map(&:to_sym)
        end
      end
    end

  end
end
