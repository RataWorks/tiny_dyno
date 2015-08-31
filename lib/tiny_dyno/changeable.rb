module TinyDyno

  # Defines behaviour for dirty tracking.
  #
  # @since 4.0.0
  module Changeable
    extend ActiveSupport::Concern

    # Get the changed attributes for the document.
    #
    # @example Get the changed attributes.
    #   model.changed
    #
    # @return [ Array<String> ] The changed attributes.
    #
    # @since 2.4.0
    # def changed
    #   binding.pry
    #   changed_attributes.keys.select { |attr| attribute_change(attr) }
    # end

    # Get the attribute changes.
    #
    # @example Get the attribute changes.
    #   model.changed_attributes
    #
    # @return [ Hash<String, Object> ] The attribute changes.
    #
    # @since 2.4.0
    # def changed_attributes
    #   @changed_attributes ||= {}
    # end

    # Get all the changes for the document.
    #
    # @example Get all the changes.
    #   model.changes
    #
    # @return [ Hash<String, Array<Object, Object> ] The changes.
    #
    # @since 2.4.0
    def changes
      _changes = {}
      changed.each do |attr|
        next if attr.nil?
        change = attribute_change(attr)
        _changes[attr] = change
      end
      _changes
    end

    private

    # Get the old and new value for the provided attribute.
    #
    # @example Get the attribute change.
    #   model.attribute_change("name")
    #
    # @param [ String ] attr The name of the attribute.
    #
    # @return [ Array<Object> ] The old and new values.
    #
    # @since 2.1.0
    def attribute_change(attr)
      attr = database_field_name(attr)
      [changed_attributes[attr], attributes[attr]] if (attribute_changed?(attr) && !attr.nil?)
    end

  end
end
