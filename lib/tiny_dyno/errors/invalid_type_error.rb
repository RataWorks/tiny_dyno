# encoding: utf-8
module TinyDyno
  module Errors

    # This error is raised, when a query is performed with fields specified
    # that are not HashKeys, which would result in a table scan
    class InvalidValueType < TinyDynoError

      # Create the new error.
      #
      # @example Instantiate the error.
      #   InvalidSelector.new(Person, "gender")
      #
      # @param [ Class ] klass The model class.
      # @param [ String, Symbol ] name The name of the attribute.
      #
      # @since 3.0.0
      def initialize(klass:, name:, value:)
        super(
            compose_message("value_not_typecasted", { klass: klass.name, name: name, value: value })
        )
      end
    end
  end
end

