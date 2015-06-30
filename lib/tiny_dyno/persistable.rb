module TinyDyno
  module Persistable
    extend ActiveSupport::Concern

    def save(options = {})
      if new_record?
        request_put_item(options)
      else
        request_update_item(options)
      end
    end

    private

    def request_put_item(options)
      request = build_put_item_request(options)
      if TinyDyno::Adapter.put_item(put_item_request: request)
        changes_applied
        @new_record = nil
        return true
      else
        return false
      end
    end

    # The target structure as per
    # http://docs.aws.amazon.com/sdkforruby/api/Aws/DynamoDB/Client.html#put_item-instance_method
    #
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
    def build_put_item_request(options)
      {
          table_name: self.class.table_name,
          item: build_item_request_entries
      }
    end

    def build_item_request_entries
      item_entries = {}
      attributes.each do |k,v|
        item_entries[k] = v
      end
      item_entries
    end

    def request_update_item(options)

    end

    module ClassMethods

      # Prepare a request to be sent to the aws-sdk
      # in compliance with
      # http://docs.aws.amazon.com/sdkforruby/api/Aws/DynamoDB/Client.html#put_item-instance_method

      def create(attributes = nil, &block)
        doc = new(attributes, &block)
        doc.save
      end

      private

    end
  end
end