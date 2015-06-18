require 'tiny_dyno/errors/simple'
require 'tiny_dyno/attributes'
require 'tiny_dyno/fields'
require 'tiny_dyno/tables'
require 'tiny_dyno/stateful'
require 'tiny_dyno/persistable'
require 'tiny_dyno/interceptable'

module TinyDyno

  # This is the base module for all domain objects that need to be persisted to
  # the database as documents.
  module Document
    extend ActiveSupport::Concern

    include TinyDyno::Attributes
    include TinyDyno::Fields
    include TinyDyno::Tables
    include TinyDyno::Stateful
    include TinyDyno::Persistable
    include TinyDyno::Interceptable

    include ActiveModel::AttributeMethods
    include ActiveModel::Conversion
    include ActiveModel::Dirty

    attr_accessor :__selected_fields
    attr_reader :new_record

    included do
      extend ActiveModel::Naming
      # include ActiveModel::ForbiddenAttributesProtection
      include ActiveModel::Validations


      TinyDyno.register_model(self)
    end

    # Instantiate a new +Document+, setting the Document's attributes if
    # given. If no attributes are provided, they will be initialized with
    # an empty +Hash+.
    #
    # The Hash Key must currently be provided from the applicationIf a HashKey is defined, the document's id will be set to that key,
    #
    # @example Create a new document.
    #   SmallPerson.new(hash_key: hash_key, title: "Sir")
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
      run_callbacks(:initialize) unless _initialize_callbacks.empty?
    end

    # Return the model name of the document.
    #
    # @example Return the model name.
    #   document.model_name
    #
    # @return [ String ] The model name.
    #
    # @since 3.0.16
    def model_name
      self.class.model_name
    end

    # Returns an instance of the specified class with the attributes,
    # errors, and embedded documents of the current document.
    #
    # @example Return a subclass document as a superclass instance.
    #   manager.becomes(SmallPerson)
    #
    # @raise [ ArgumentError ] If the class doesn't include TinyDyno::Document
    #
    # @param [ Class ] klass The class to become.
    #
    # @return [ Document ] An instance of the specified class.
    #
    # @since 2.0.0
    def becomes(klass)
      unless klass.include?(TinyDyno::Document)
        raise ArgumentError, "A class which includes TinyDyno::Document is expected"
      end

      became = klass.new(clone_document)
      became._id = _id
      became.instance_variable_set(:@changed_attributes, changed_attributes)
      became.instance_variable_set(:@errors, ActiveModel::Errors.new(became))
      became.errors.instance_variable_set(:@messages, errors.instance_variable_get(:@messages))
      became.instance_variable_set(:@new_record, new_record?)
      became.instance_variable_set(:@destroyed, destroyed?)
      became.changed_attributes["_type"] = self.class.to_s
      became._type = klass.to_s
      became
    end

    # Print out the cache key. This will append different values on the
    # plural model name.
    #
    # If new_record?     - will append /new
    # If not             - will append /id-updated_at.to_s(:nsec)
    # Without updated_at - will append /id
    #
    # This is usually called insode a cache() block
    #
    # @example Returns the cache key
    #   document.cache_key
    #
    # @return [ String ] the string with or without updated_at
    #
    # @since 2.4.0
    def cache_key
      return "#{model_key}/new" if new_record?
      return "#{model_key}/#{id}-#{updated_at.utc.to_s(:nsec)}" if do_or_do_not(:updated_at)
      "#{model_key}/#{id}"
    end

    def relations
      {}
    end

    private

    # # Returns the logger
    # #
    # # @return [ Logger ] The configured logger or a default Logger instance.
    # #
    # # @since 2.2.0
    # def logger
    #   TinyDyno.logger
    # end

    # Get the name of the model used in caching.
    #
    # @example Get the model key.
    #   model.model_key
    #
    # @return [ String ] The model key.
    #
    # @since 2.4.0
    def model_key
      @model_cache_key ||= self.class.model_name.cache_key
    end

    # Implement this for calls to flatten on array.
    #
    # @example Get the document as an array.
    #   document.to_ary
    #
    # @return [ nil ] Always nil.
    #
    # @since 2.1.0
    def to_ary
      nil
    end

    module ClassMethods

      # Performs class equality checking.
      #
      # @example Compare the classes.
      #   document === other
      #
      # @param [ Document, Object ] other The other object to compare with.
      #
      # @return [ true, false ] True if the classes are equal, false if not.

      def ===(other)
        other.class == Class ? self <= other : other.is_a?(self)
      end


      # Returns the logger
      #
      # @example Get the logger.
      #   SmallPerson.logger
      #
      # @return [ Logger ] The configured logger or a default Logger instance.
      #
      # @since 2.2.0
      def logger
        TinyDyno.logger
      end
    end
  end
end

ActiveSupport.run_load_hooks(:tiny_dyno, TinyDyno::Document)
