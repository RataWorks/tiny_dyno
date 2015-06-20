module TinyDyno
  module Adapter
    extend self

    def update_item(update_item_request:)
      connection.update_item(update_item_request).successful?
    end

    def put_item(put_item_request:)
      connection.put_item(put_item_request).successful?
    end

  end
end