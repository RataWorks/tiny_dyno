# encoding: utf-8
module TinyDyno
  module Fields
    class Standard

      # Defines the behaviour for defined fields in the document.
      # Set readers for the instance variables.
      attr_accessor :default_val, :label, :name, :options

      delegate :from_dyno, :to_dyno, to: :type

      # Create the new field with a name and optional additional options.
      #
      # @example Create the new field.
      #   Field.new(:name, :type => String)
      #
      # @param [ Hash ] options The field options.
      #
      # @option options [ Class ] :type The class of the field.
      # @option options [ Object ] :default The default value for the field.
      # @option options [ String ] :label The field's label.
      #
      # @since 3.0.0
      def initialize(name, options = {})
        @name = name
        @options = options
        @label = options[:label]
        @default_val = options[:default]

        # @todo: Durran, change API in 4.0 to take the class as a parameter.
        # This is here temporarily to address #2529 without changing the
        # constructor signature.
        if default_val.respond_to?(:call)
          define_default_method(options[:klass])
        end
      end

      # Get the type of this field - inferred from the class name.
      #
      # @example Get the type.
      #   field.type
      #
      # @return [ Class ] The name of the class.
      #
      # @since 2.1.0
      def type
        @type = options[:type]
      end

      private

      # Is the field included in the fields that were returned from the
      # database? We can apply the default if:
      #   1. The field is included in an only limitation (field: 1)
      #   2. The field is not excluded in a without limitation (field: 0)
      #
      # @example Is the field included?
      #   field.included?(fields)
      #
      # @param [ Hash ] fields The field limitations.
      #
      # @return [ true, false ] If the field was included.
      #
      # @since 2.4.4
      def included?(fields)
        (fields.values.first == 1 && fields[name.to_s] == 1) ||
            (fields.values.first == 0 && !fields.has_key?(name.to_s))
      end

    end
  end
end
