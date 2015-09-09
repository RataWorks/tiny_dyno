module TinyDyno
  module Adapter
    extend self

    def update_item(update_item_request:)
      connection.update_item(update_item_request).successful?
    end

    def put_item(put_item_request:)
      connection.put_item(put_item_request).successful?
    end

    def get_item(get_item_request:)
      resp = connection.get_item(get_item_request)
      return nil if resp.item.nil?
      typed_attributes = {}
      resp.item.each {|k,v| typed_attributes[k] = TinyDyno::Adapter.doc_attribute(v) }
      typed_attributes
    end

    def delete_item(request:)
      connection.delete_item(request).successful?
    end

  end
end