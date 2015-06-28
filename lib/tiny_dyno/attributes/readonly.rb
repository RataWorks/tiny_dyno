# encoding: utf-8
module TinyDyno
  module Attributes

    # This module defines behaviour for readonly attributes.
    module Readonly
      extend ActiveSupport::Concern

      included do
        class_attribute :readonly_attributes
        self.readonly_attributes = ::Set.new
      end

      # Are we able to write the attribute with the provided name?
      #
      # @example Can we write the attribute?
      #   model.attribute_writable?(:title)
      #
      # @param [ String, Symbol ] name The name of the field.
      #
      # @return [ true, false ] If the document is new, or if the field is not
      #   readonly.
      #
      # @since 3.0.0
      def attribute_writable?(name)
        new_record? || !readonly_attributes.include?(database_field_name(name))
      end

      module ClassMethods

        # Defines an attribute as readonly. This will ensure that the value for
        # the attribute is only set when the document is new or we are
        # creating. In other cases, the field write will be ignored with the
        # exception of #remove_attribute and #update_attribute, where an error
        # will get raised.
        #
        # @example Flag fields as readonly.
        #   class Band
        #     include TinyDyno::Document
        #     field :name, type: String
        #     field :genre, type: String
        #     attr_readonly :name, :genre
        #   end
        #
        # @param [ Array<Symbol> ] names The names of the fields.
        #
        # @since 3.0.0
        def attr_readonly(*names)
          names.each do |name|
            readonly_attributes << database_field_name(name)
          end
        end
      end
    end
  end
end
