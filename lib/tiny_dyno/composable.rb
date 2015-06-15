# encoding: utf-8

require 'tiny_dyno/persistable'
require 'tiny_dyno/stateful'

module TinyDyno

  # This module provides inclusions of all behaviour in a TinyDyno document.
  #
  # @since 4.0.0
  module Composable
    extend ActiveSupport::Concern

    # All modules that a +Document+ is composed of are defined in this
    # module, to keep the document class from getting too cluttered.
    # TODO re enable
    # included do
      # extend Findable
    # end

    include ActiveModel::Model
    include ActiveModel::ForbiddenAttributesProtection
    include ActiveModel::Serializers::JSON
    include ActiveModel::Serializers::Xml

    include Attributes
    include Fields
    include Persistable
    include Stateful

    MODULES = [
      Attributes,
      Fields,
      Persistable,
      Stateful,
      ActiveModel::Model,
      ActiveModel::Validations
    ]

    class << self

      # Get a list of methods that would be a bad idea to define as field names
      # or override when including TinyDyno::Document.
      #
      # @example Bad thing!
      #   TinyDyno::Components.prohibited_methods
      #
      # @return [ Array<Symbol> ]
      #
      # @since 2.1.8
      def prohibited_methods
        @prohibited_methods ||= MODULES.flat_map do |mod|
          mod.instance_methods.map(&:to_sym)
        end
      end
    end
  end
end
