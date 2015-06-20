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

    module ClassMethods

    end

  end
end