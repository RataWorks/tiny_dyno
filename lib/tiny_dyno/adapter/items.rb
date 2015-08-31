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
      if resp.respond_to?(:item)
        resp.item
      else
        nil
      end
    end

    def delete_item(request:)
      connection.delete_item(request).successful?
    end

  end
end