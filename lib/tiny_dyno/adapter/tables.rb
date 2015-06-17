module TinyDyno
  module Adapter
    extend self

    # Terminology in here is directly derived from the aws sdk language
    #
    # http://docs.aws.amazon.com/sdkforruby/api/Aws/DynamoDB/Client.html#create_table-instance_method
    #
    # The current implementation is a strict 1:1 relation of 1 Model to 1 table

    # Answer, whether a table is present, first by cache lookup and if miss on datastore
    #
    # @example Does the table exists?
    #   TinyDyno::Adapter.table_exists?(table_name: Person.table_name)
    # @return [ true ] if the table is present

    def table_exists?(table_name:)
      return true if @table_names.include?(table_name)
      update_table_cache
      @table_names.include?(table_name)
    end

    # http://docs.aws.amazon.com/sdkforruby/api/Aws/DynamoDB/Client.html#create_table-instance_method
    # expect create_table_request to conform to above schema
    #
    # Send the actual table creation to DynamoDB
    #
    # @example Create the table for the class
    #   Person.create_table
    #
    # @return [ true ] if the operation succeeds

    def create_table(create_table_request)
      table_settings = {
          provisioned_throughput: {
              read_capacity_units: 200,
              write_capacity_units: 200,
          },
      }.merge!(create_table_request)

      # Should or shouldn't we?
      # begin
      #   resp = connection.describe_table(table_name: table_settings[:table_name])
      # rescue Aws::DynamoDB::Errors::ResourceNotFoundException
      # ensure
      #   if resp.respond_to?(:table)
      #     p "Warning, table was already present : #{ table_settings[:table_name]}"
      #   end
      # end
      connection.create_table(table_settings)
      if wait_on_table_status(table_status: :table_exists, table_name: table_settings[:table_name])
        update_table_cache
        return true
      else
        return false
      end
    end

    def delete_table(table_name:)
      begin
        connection.describe_table(table_name: table_name)
      rescue Aws::DynamoDB::Errors::ResourceNotFoundException
        # table not there anyway
        return true
      end
      if wait_on_table_status(table_status: :table_exists, table_name: table_name)
        connection.delete_table(table_name: table_name)
      else
        return false
      end
      wait_on_table_status(table_status: :table_not_exists, table_name: table_name)
      update_table_cache
      return true unless table_exists?(table_name: table_name)
      return false
    end

    # Hold a cache of available table names in an instance variable
    #
    def update_table_cache
      @table_names = connection.list_tables.table_names
    end

    private

    # Use the aws-sdk provided waiter methods to wait on either
    # table_exists, table_not_exists
    def wait_on_table_status(table_status:, table_name:)
      begin
        connection.wait_until(table_status, table_name: table_name) do |w|
          w.interval = 1
          w.max_attempts = 10
        end
      rescue Aws::Waiters::Errors => e
        p "Waiter failed: #{ e .inspect }"
        return false
      end
      return true
    end


  end
end