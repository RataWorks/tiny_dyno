module TinyDyno
  module Fields
    class RangeKey

      # Defines the behaviour for defined fields in the document.
      # Set readers for the instance variables.
      attr_accessor :default_val, :label, :name, :options

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
        @type = options[:type]
      end

    end
  end
end