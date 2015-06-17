module TinyDyno
  module Persistable
    extend ActiveSupport::Concern
    #
    # module ClassMethods
    #
    #   # Prepare a request to be sent to the aws-sdk
    #   # in compliance with
    #   # http://docs.aws.amazon.com/sdkforruby/api/Aws/DynamoDB/Client.html#put_item-instance_method
    #
    #   def create(attributes = nil, &block)
    #     doc = new(attributes, &block)
    #     doc.save
    #   end
    #
    #   def save(options = {})
    #     if new_record?
    #       request_put_item(options).new_record?
    #     else
    #       request_update_item(options)
    #     end
    #   end
    #
    #   private
    #
    #   def request_put_item(options)
    #     binding.pry
    #   end
    #
    #   def request_update_item(options)
    #
    #   end
    #
    # end

  end
end