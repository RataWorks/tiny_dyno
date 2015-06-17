require 'aws-sdk'

require 'tiny_dyno/adapter/tables'

module TinyDyno

  # Interactions with the DynamoDB store through aws-sdk-v2
  module Adapter
    extend ActiveSupport::Concern
    extend self

    attr_reader :table_names

    @table_names = []

    def connect
      connection
      connected?
    end

    def connected?
      return true if @connection.class == Aws::DynamoDB::Client
      return false
    end

    def disconnect!
      @connection = nil
    end

    def update_item(update_item_request)
      false
    end
    def put_item(put_item_request:)
      false
    end

    protected

    def connection
      unless @connection
        TinyDyno.logger.info 'setting up new connection ... ' if TinyDyno.logger
        @connection =  Aws::DynamoDB::Client.new
        update_table_cache
      end
      @connection
    end

  end
end