
module TinyDyno
  module Tables
    extend ActiveSupport::Concern

    included do
      class_attribute :provisioned_throughput

      self.provisioned_throughput ||= {
          read_capacity_units: 100,
          write_capacity_units: 100,
      }

    end

    module ClassMethods

      def table_name
        self.name.to_s.downcase
      end

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

      # Send the actual table creation to the DynamoDB API
      # and expect no table to be present
      # @example Create the table for the class
      #   Person.create_table!
      # @return [ true ] If the operation succeeded
      def create_table!
        raise InvalidTableDefinition.new "#{ self.name } has invalid table configuration" unless model_table_config_is_valid?
        TinyDyno::Adapter.create_table(create_table_request)
      end


      # Soft Create Request,
      # which will accept that a table may already exist
      # @example Create the table for the class
      # @return [ true ] If the operation succeeded <or> the table was already created
      def create_table
        if TinyDyno::Adapter.table_exists?(table_name: self.table_name)
          return true
        end
        raise InvalidTableDefinition.new "#{ self.name } has invalid table configuration" unless model_table_config_is_valid?
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

      def model_table_config_is_valid?
        return (attribute_definitions_meet_spec? and not self.table_name.nil?)
      end

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
    end

  end
end