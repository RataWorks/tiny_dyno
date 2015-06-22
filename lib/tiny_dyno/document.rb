require 'tiny_dyno/document_composition'

module TinyDyno
  module Document

    extend ActiveSupport::Concern
    extend ActiveModel::Naming
    include ActiveModel::Dirty
    include ActiveModel::Model

    include DocumentComposition

    included do
      TinyDyno.register_model(self)
    end

    # Instantiate a new +Document+, setting the Document's attributes if
    # given. If no attributes are provided, they will be initialized with
    # an empty +Hash+.
    #
    # The Hash Key must currently be provided from the applicationIf a HashKey is defined, the document's id will be set to that key,
    #
    # @example Create a new document.
    #   Person.new(hash_key: hash_key, title: "Sir")
    #
    # @param [ Hash ] attrs The attributes to set up the document with.
    #
    # @return [ Document ] A new document.
    # @since 1.0.0
    def initialize(attrs = nil)
      @new_record = true
      @attributes ||= {}
      process_attributes(attrs) do
        yield(self) if block_given?
      end
      # run_callbacks(:initialize) unless _initialize_callbacks.empty?
      # raise ::TinyDyno::Errors::MissingHashKey.new(self.name) unless @hash_key.is_a?(Hash)
    end

    def delete
      request_delete
    end

    private

    def request_delete
      request = {
          table_name: self.class.table_name,
          key: hash_key_as_selector
      }
      TinyDyno::Adapter.delete_item(request: request)
    end

    module ClassMethods

      def where(options = {})
        valid_option_keys(options)
        get_query = build_where_query(options)
        attributes = TinyDyno::Adapter.get_item(get_item_request: get_query)
        if attributes.nil?
          return false
        else
          self.new(attributes)
        end
      end

      private

      # minimimum implementation for now
      # check that each option key relates to a hash_key present on the model
      # do not permit scan queries
      def valid_option_keys(options)
        options.keys.each do |name|
          named = name.to_s
          raise TinyDyno::Errors::HashKeysOnly.new(klass: self.class, name: named) unless hash_key_is_defined?(named)
        end
      end

      # minimimum implementation for now
      # build simple query to retrieve document
      # via get_item
      # http://docs.aws.amazon.com/sdkforruby/api/Aws/DynamoDB/Client.html#get_item-instance_method
      def build_where_query(options)
        query_keys = {}
        options.each do |k,v|
          # as expected by DynamoDB
          typed_key = k.to_s
          query_keys[typed_key] = dyno_typed_key(key: typed_key, val: v)
        end
        {
            table_name: self.table_name,
            attributes_to_get: attribute_names,
            key: query_keys
        }
      end

    end

  end
end