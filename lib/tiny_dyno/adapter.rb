require 'aws-sdk'

module TinyDyno

  # Interactions with the DynamoDB store through aws-sdk-v2
  module Adapter
    extend ActiveSupport::Concern
    extend self

    attr_reader :table_names

    @connection = Aws::DynamoDB::Client.new
    @table_names = []

    def connect
      reconnect unless @connection.class == Aws::DynamoDB::Client
      connection
      return true if @connection.class == Aws::DynamoDB::Client
      return false
    end
    def connected?
      return true if @connection.class == Aws::DynamoDB::Client
      return false
    end

    def disconnect!
      @connection = nil
    end

    def table_exists?(table_name:)
      return true if table_names.include?(table_name)
      update_table_cache
      table_names.include?(table_name)
    end

    #  http://docs.aws.amazon.com/sdkforruby/api/Aws/DynamoDB/Client.html#create_table-instance_method
    # resp = client.create_table({
    #                                attribute_definitions: [ # required
    #                                    {
    #                                        attribute_name: "KeySchemaAttributeName", # required
    #                                        attribute_type: "S", # required, accepts S, N, B
    #                                    },
    #                                ],
    #                                table_name: "TableName", # required
    #                                key_schema: [ # required
    #                                    {
    #                                        attribute_name: "KeySchemaAttributeName", # required
    #                                        key_type: "HASH", # required, accepts HASH, RANGE
    #                                    },
    #                                ],
    #                                local_secondary_indexes: [
    #                                    {
    #                                        index_name: "IndexName", # required
    #                                        key_schema: [ # required
    #                                            {
    #                                                attribute_name: "KeySchemaAttributeName", # required
    #                                                key_type: "HASH", # required, accepts HASH, RANGE
    #                                            },
    #                                        ],
    #                                        projection: { # required
    #                                                      projection_type: "ALL", # accepts ALL, KEYS_ONLY, INCLUDE
    #                                                      non_key_attributes: ["NonKeyAttributeName"],
    #                                        },
    #                                    },
    #                                ],
    #                                global_secondary_indexes: [
    #                                    {
    #                                        index_name: "IndexName", # required
    #                                        key_schema: [ # required
    #                                            {
    #                                                attribute_name: "KeySchemaAttributeName", # required
    #                                                key_type: "HASH", # required, accepts HASH, RANGE
    #                                            },
    #                                        ],
    #                                        projection: { # required
    #                                                      projection_type: "ALL", # accepts ALL, KEYS_ONLY, INCLUDE
    #                                                      non_key_attributes: ["NonKeyAttributeName"],
    #                                        },
    #                                        provisioned_throughput: { # required
    #                                                                  read_capacity_units: 1, # required
    #                                                                  write_capacity_units: 1, # required
    #                                        },
    #                                    },
    #                                ],
    #                                provisioned_throughput: { # required
    #                                                          read_capacity_units: 1, # required
    #                                                          write_capacity_units: 1, # required
    #                                },
    #                            })
    # expect create_table_request to conform to above schema
    def create_table(create_table_request)
      table_settings = {
          provisioned_throughput: {
              read_capacity_units: 200,
              write_capacity_units: 200,
          },
      }.merge!(create_table_request)

      # I'm not so fond of fudging over the fact, that we just gloss over the fact
      # that the table already exists ...
      # TODO++ add a logging scope and raise a warning at least
      begin
        resp = connection.describe_table(table_name: table_settings[:table_name])
      rescue Aws::DynamoDB::Errors::ResourceNotFoundException
      ensure
        if resp.respond_to?(:table)
          p "Warning, table was already present : #{ table_settings[:table_name]}"
        end
      end
      resp = connection.create_table(table_settings)
      if wait_on_table_status(table_status: :table_exists, table_name: table_settings[:table_name])
        update_table_cache
        return true
      else
        return false
      end
    end

    def delete_table(table_name:)
      begin
        resp = connection.describe_table(table_name: table_name)
      rescue Aws::DynamoDB::Errors::ResourceNotFoundException
        # table not there anyway
        return true
      end
      if wait_on_table_status(table_status: :table_exists, table_name: table_name)
        resp = connection.delete_table(table_name: table_name)
      else
        return false
      end
      wait_on_table_status(table_status: :table_not_exists, table_name: table_name)
      update_table_cache
      return false if table_exists?(table_name: table_name)
      return true
    end

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

    def update_item(update_item_request)
      binding.pry
    end

    # as per http://docs.aws.amazon.com/sdkforruby/api/Aws/DynamoDB/Client.html#put_item-instance_method
    # resp = client.put_item({
    #                            table_name: "TableName", # required
    #                            item: { # required
    #                                    "AttributeName" => "value", # value <Hash,Array,String,Numeric,Boolean,IO,Set,nil>
    #                            },
    #                            expected: {
    #                                "AttributeName" => {
    #                                    value: "value", # value <Hash,Array,String,Numeric,Boolean,IO,Set,nil>
    #                                    exists: true,
    #                                    comparison_operator: "EQ", # accepts EQ, NE, IN, LE, LT, GE, GT, BETWEEN, NOT_NULL, NULL, CONTAINS, NOT_CONTAINS, BEGINS_WITH
    #                                    attribute_value_list: ["value"], # value <Hash,Array,String,Numeric,Boolean,IO,Set,nil>
    #                                },
    #                            },
    #                            return_values: "NONE", # accepts NONE, ALL_OLD, UPDATED_OLD, ALL_NEW, UPDATED_NEW
    #                            return_consumed_capacity: "INDEXES", # accepts INDEXES, TOTAL, NONE
    #                            return_item_collection_metrics: "SIZE", # accepts SIZE, NONE
    #                            conditional_operator: "AND", # accepts AND, OR
    #                            condition_expression: "ConditionExpression",
    #                            expression_attribute_names: {
    #                                "ExpressionAttributeNameVariable" => "AttributeName",
    #                            },
    #                            expression_attribute_values: {
    #                                "ExpressionAttributeValueVariable" => "value", # value <Hash,Array,String,Numeric,Boolean,IO,Set,nil>
    #                            },
    #                        })
    def put_item(put_item_request:)

    end

    def update_table_cache
      @table_names = connection.list_tables.table_names
    end

    protected

    def connection
      unless @connection
        p 'setting up new connection ... '
        @connection =  Aws::DynamoDB::Client.new
        update_table_cache
      end
      @connection
    end

  end
end