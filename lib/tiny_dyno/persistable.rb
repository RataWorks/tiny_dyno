module TinyDyno
  module Persistable
    extend ActiveSupport::Concern

    def save(options = {})
      if new_record?
        if request_put_item(options)
          changes_applied
          @new_record = nil
          return true
        else
          return false
        end
      else
        if request_update_item(options)
          changes_applied
          return true
        else
          return false
        end
      end
    end

    private

    def request_put_item(options)
      request = request_as_new_record(build_put_item_request)
      return(TinyDyno::Adapter.put_item(put_item_request: request))
    end

    def request_update_item(options)
      request = build_update_item_request
      return(TinyDyno::Adapter.update_item(update_item_request: request))
    end

    def build_put_item_request
      {
          table_name: self.class.table_name,
          item: build_item_request_entries
      }
    end

    def build_update_item_request
      {
          key: hash_key_as_selector,
          table_name: self.class.table_name,
          attribute_updates: build_attribute_updates
      }
    end

    def build_item_request_entries
      item_entries = {}
      attributes.each { |k,v| item_entries[k] = v }
      item_entries
    end

    #  attribute_updates: {
    # "AttributeName" => {
    #     value: "value", # value <Hash,Array,String,Numeric,Boolean,IO,Set,nil>
    #     action: "ADD", # accepts ADD, PUT, DELETE
    # },
    def build_attribute_updates
      change_record = []
      changes.keys.each do |change_key|
        if self.class.attribute_names.include?(change_key)
          change_record << {:"#{ change_key}" => changes[change_key]}
        end
      end
      # keep this simple for now
      # I don't see (yet) how to map the possible operations on dynamodb items
      # into activerecord compatible schemas
      # extend as use cases arise
      # specification by example ...
      attribute_updates = {}
      change_record.each do |change|
        change_key = change.keys.first
        if change[change_key][1].nil?
          attribute_updates[change_key] = {
              action: 'DELETE'
          }
        else
          attribute_updates[change_key] = {
              value:  change[change_key][1],
              action: 'PUT'
          }
        end
      end
      attribute_updates
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