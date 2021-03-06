module TinyDyno
  module Persistable
    extend ActiveSupport::Concern

    def save(options = {})
      unless options.has_key?(:validate) && options[:validate] == false
        return false unless self.valid?
      end
      remove_empty_attributes
      if new_record?
        if request_put_item(options)
          changes_applied
          @new_record = nil
          return true
        else
          return false
        end
      else
        if request_replace_item(options)
          changes_applied
          return true
        else
          return false
        end
      end
    end

    private

    def remove_empty_attributes
      self.class.fields
      @attributes.each_pair do |k,v|
        next unless self.class.fields[k].options[:type].to_s == 'String'
        next unless v.respond_to?(:to_s)
        @attributes.delete(k) if v.to_s.nil? or v.to_s.empty?
      end
    end

    def request_put_item(options)
      request = request_as_new_record(build_put_item_request)
      return(TinyDyno::Adapter.put_item(put_item_request: request))
    end

    def request_replace_item(options)
      request = build_put_item_request
      return(TinyDyno::Adapter.put_item(put_item_request: request))
    end

    def build_put_item_request
      {
          table_name: self.class.table_name,
          item: build_item_request_entries
      }
    end

    def build_item_request_entries
      item_entries = {}
      attributes.each { |k,v| item_entries[k] = TinyDyno::Adapter.aws_attribute(field_type: fields[k].options[:type], value: v) }
      item_entries
    end

    #  attribute_updates: {
    # "AttributeName" => {
    #     value: "value", # value <Hash,Array,String,Numeric,Boolean,IO,Set,nil>
    #     action: "ADD", # accepts ADD, PUT, DELETE
    # },
    # def build_attribute_updates
    #   change_record = []
    #   changes.keys.each do |change_key|
    #     if self.class.attribute_names.include?(change_key)
    #       change_record << {:"#{ change_key}" => changes[change_key]}
    #     end
    #   end
    #   # keep this simple for now
    #   # I don't see (yet) how to map the possible operations on dynamodb items
    #   # into activerecord compatible schemas
    #   # extend as use cases arise
    #   # specification by example ...
    #   attribute_updates = {}
    #   change_record.each do |change|
    #     change_key = change.keys.first
    #     if change[change_key][1].nil?
    #       attribute_updates[change_key] = {
    #           action: 'DELETE'
    #       }
    #     else
    #       attribute_updates[change_key] = {
    #           value:  change[change_key][1],
    #           action: 'PUT'
    #       }
    #     end
    #   end
    #   attribute_updates
    # end

    module ClassMethods

      # Prepare a request to be sent to the aws-sdk
      # in compliance with
      # http://docs.aws.amazon.com/sdkforruby/api/Aws/DynamoDB/Client.html#put_item-instance_method

      def create(attributes = nil, &block)
        doc = new(attributes, &block)
        if doc.save
          doc
        else
          nil
        end
      end

      private

    end
  end
end