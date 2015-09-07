module TinyDyno
  module HashKey
    extend ActiveSupport::Concern

    included do
      class_attribute :attribute_definitions, :key_schema, :primary_key

      # TODO :local_secondary_indexes, :global_secondary_indexes
      self.attribute_definitions ||= []
      self.key_schema ||= []
      self.primary_key ||= {}
    end

    # return all defined hash keys on an instantiated object
    # for further use in DynamoDB queries, i.e. to look up an object
    #
    def hash_key_as_selector
      key_field = self.class.primary_key[:attr]
      { "#{ self.class.primary_key[:attr] }": TinyDyno::Adapter.aws_attribute(field_type: fields[key_field].options[:type], value: attributes[key_field]) }
    end

    module ClassMethods

      # Defines the primary key for the Document
      # Only one primary key = hash_key is allowed in DynamoDB
      #
      # @example Define a field.
      #   hash_key :score, :type => Integer
      #
      # @param [ Symbol ] name The name of the hash_key.
      # @param [ Hash ] options The options to pass to the hash_key.
      #
      # @option options [ Class ] :type The type of the field.
      # @option options [ String ] :label The label for the field.
      #
      # @return [ Field ] The generated field
      def hash_key(name, options = {})
        raise TinyDyno::Errors::OnlyOneHashKeyPermitted.new(klass: self.class, name: name) unless primary_key.empty?
        named = name.to_s
        attribute_definition = build_attribute_definition(named,options[:type])
        key_schema = hash_key_schema(named)
        unless attribute_definition_meets_spec?(attribute_definition)
          raise TinyDyno::Errors::InvalidHashKey.new(klass: self.class, name: name)
        end
        # we need the accessors as well
        add_field(named, options)
        self.attribute_definitions << attribute_definition
        self.key_schema << key_schema
        self.primary_key = {
            attr: attribute_definition[:attribute_name],
            attr_type: attribute_definition[:attribute_type],
            key_type: key_schema[:key_type],
        }
      end

      private

      # Return true or false, depending on whether the attribute_definitions on the model
      # meet the specification of the Aws Sdk
      # This is a syntax, not a logic check
      def attribute_definitions_meet_spec?
        attribute_definitions.each do |definition|
          return false unless attribute_definition_meets_spec?(definition)
        end
      end

      def attribute_definition_meets_spec?(definition)
        return (definition.has_key?(:attribute_name) && \
        definition.has_key?(:attribute_type) && \
        definition[:attribute_name].class == String && \
        definition[:attribute_type].class == String && \
        ['S','N', 'B'].include?(definition[:attribute_type]))
      end

      def build_attribute_definition(name, key_type)
        {
            attribute_name: name,
            attribute_type: determine_key_class(key_type)
        }
      end

      def determine_key_class(key_type = nil)
        return 'S' if key_type == String
        return 'N' if key_type == Fixnum or key_type == Integer
        return nil
      end

      def hash_key_schema(name)
        {
            attribute_name: name,
            key_type: 'HASH'
        }
      end

      # convert values in queries to DynamoDB
      # into types as expected by DynamoDB
      def dyno_typed_key(key:, val:)
        field_type = self.fields[key].options[:type]
        return (TinyDyno::Adapter.aws_attribute(field_type: field_type, value: val))
      end

    end
  end
end