require 'pry'

module TinyDyno
  module Tables
    extend ActiveSupport::Concern

    included do
      class_attribute :table_name, :attribute_definitions, :key_schema, :provisioned_throughput
      # TODO :local_secondary_indexes, :global_secondary_indexes

      self.table_name = self.name.to_s.downcase
      self.attribute_definitions = []
      self.key_schema = []

      self.provisioned_throughput ||= {
          read_capacity_units: 100,
          write_capacity_units: 100,
      }

    end

    module ClassMethods

      class << self

        # Stores the provided block to be run when the option name specified is
        # defined on a field.
        #
        # No assumptions are made about what sort of work the handler might
        # perform, so it will always be called if the `option_name` key is
        # provided in the field definition -- even if it is false or nil.
        #
        # @example
        #   TinyDyno::Tables.option :required do |model, field, value|
        #     model.validates_presence_of field if value
        #   end
        #
        # @param [ Symbol ] option_name the option name to match against
        # @param [ Proc ] block the handler to execute when the option is
        #   provided.
        #
        # @since 2.1.0
        def option(option_name, &block)
          options[option_name] = block
        end

        # Return a map of custom option names to their handlers.
        #
        # @example
        #   TinyDyno::Tables.options
        #   # => { :required => #<Proc:0x00000100976b38> }
        #
        # @return [ Hash ] the option map
        #
        # @since 2.1.0
        def options
          @options ||= {}
        end
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
          raise InvalidHashKeyDefinitionError, "#{ name } on #{ self.name }"
        end
        self.attribute_definitions << attribute_definition
        self.key_schema << key_schema
      end

      # Send the actual table creation to the DynamoDB API
      # @example Create the table for the class
      #   Person.create_table
      # @return [ true ] If the operation succeeded

      def create_table
        raise InvalidTableDefinitionError, "#{ self.name } has invalid table configuration" unless model_table_config_is_valid?
        TinyDyno::Adapter.create_table(create_table_request)
      end

      # Request the table to be deleted
      # @example Delete the table for the class
      #   Person.delete_table
      # @return [ true ] If the operation succeeded

      def delete_table
        TinyDyno::Adapter.delete_table(table_name: self.table_name)
      end

      # Return the actual table name that represents the model in the DynamoDB store
      # @example Return the table name for the class
      #   Person.table_name
      #
      # @return [ String ] The name of the table

      private

      # build create_table_request, as expected by aws-sdk v2 #create_table
      # http://docs.aws.amazon.com/sdkforruby/api/Aws/DynamoDB/Client.html#create_table-instance_method
      def create_table_request
        {
            table_name: self.table_name.to_s,
            attribute_definitions: self.attribute_definitions,
            key_schema: self.key_schema,
            provisioned_throughput: self.provisioned_throughput
        }
      end

      def model_table_config_is_valid?
        return (attribute_definitions_meet_spec? and not self.table_name.nil?)
      end
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

    end
  end
end