# encoding: utf-8
module TinyDyno
  module Errors

    # This error is raised when trying to set a value in TinyDyno that is not
    # already set with dynamic attributes or the field is not defined.
    class UnknownAttribute < TinyDynoError

      # Create the new error.
      #
      # @example Instantiate the error.
      #   UnknownAttribute.new(Person, "gender")
      #
      # @param [ Class ] klass The model class.
      # @param [ String, Symbol ] name The name of the attribute.
      #
      # @since 3.0.0
      def initialize(klass, name)
        super(
            compose_message("unknown_attribute", { klass: klass.name, name: name })
        )
      end
    end
  end
end
