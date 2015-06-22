module TinyDyno
  module HashKeys
    extend ActiveSupport::Concern

    included do
      class_attribute :attribute_definitions, :key_schema, :hash_keys

      # TODO :local_secondary_indexes, :global_secondary_indexes
      self.attribute_definitions = []
      self.key_schema = []
      self.hash_keys = []
      @hash_key_fields = []

    end

    # return all defined hash keys on an instantiated object
    # for further use in DynamoDB queries
    #
    def hash_key_as_selector
      selector = {}
      self.class.hash_keys.each { |hk| selector[hk[:attr]] = attributes[hk[:attr]] }
      selector
    end

    module ClassMethods

      # Return true/false, depending on whether the provided argument
      # matches a defined hash key for this document model
      # @example Hash key is defined?
      #   Person.hash_key_is_defined?(:id)
      #
      # @param [ String ] name, the name of the hash key
      # @return [ Boolean ] True, False
      def hash_key_is_defined?(arg = nil)
        @hash_key_fields.include?(arg)
      end

      # return the attribute_type as stored in the attribute_definitions
      def lookup_attribute_type(attribute_name)
        type = attribute_definitions.collect {|a| a[:attribute_type] if a[:attribute_name] == attribute_name }
        type.first
      end

      # Defines all the fields that are accessible on the Document
      # For each field that is defined, a getter and setter will be
      # added as an instance method to the Document.
      #
      # @example Define a field.
      #   field :score, :type => Integer, :default => 0
      #
      # @param [ Symbol ] name The name of the field.
      # @param [ Hash ] options The options to pass to the field.
      #
      # @option options [ Class ] :type The type of the field.
      # @option options [ String ] :label The label for the field.
      # @option options [ Object, Proc ] :default The field's default
      #
      # @return [ Field ] The generated field
      def hash_key(name, options = {})
        named = name.to_s
        attribute_definition = build_attribute_definition(named,options[:type])
        key_schema = build_key_schema(named)
        unless attribute_definition_meets_spec?(attribute_definition)
          raise InvalidHashKey.new(self.class, name)
        end
        # we need the accessors as well
        add_field(named, options)
        self.attribute_definitions << attribute_definition
        self.key_schema << key_schema
        # TODO
        # should separate that out
        self.hash_keys << {
            attr: attribute_definition[:attribute_name],
            attr_type: attribute_definition[:attribute_type],
            key_type: key_schema[:key_type],
        }
        @hash_key_fields << attribute_definition[:attribute_name]
      end

      # convert a hash key into a format as expected by
      # put_item and update_item request
      def as_item_entry(hash_key)

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
            attribute_type: hash_key_type(key_type)
        }
      end

      def hash_key_type(key_type = nil)
        return 'S' if key_type == String
        return 'N' if key_type == Fixnum or key_type == Integer
        return nil
      end

      def build_key_schema(name)
        {
            attribute_name: name,
            key_type: 'HASH'
        }
      end

      # convert values in queries to DynamoDB
      # into types as expected by DynamoDB
      def dyno_typed_key(key:, val:)
        typed_class = self.fields[key].options[:type]
        return (document_typed(klass: typed_class, value: val))
      end

    end
  end
end