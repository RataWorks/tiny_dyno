require 'active_model/attribute_methods'

require 'tiny_dyno/attributes/readonly'

module TinyDyno
  module Attributes

    extend ActiveSupport::Concern

    include Readonly

    attr_reader :attributes

    # Write a single attribute to the document attribute hash. This will
    # also fire the before and after update callbacks, and perform any
    # necessary typecasting.
    # called from within ActiveModel
    #
    # @example Write the attribute.
    #   person.write_attribute(:title, "Mr.")
    #
    # @example Write the attribute (alternate syntax.)
    #   person[:title] = "Mr."
    #
    # @param [ String, Symbol ] name The name of the attribute to update.
    # @param [ Object ] value The value to set for the attribute.
    #
    # @since 1.0.0
    def write_attribute(name, value)
      access = database_field_name(name.to_s)
      typed_value = typed_value_for(access, value)
      if attribute_writable?(access)
        unless attributes[access] == typed_value|| attribute_changed?(access)
          attribute_will_change!(access)
        end
        attributes[access] = typed_value
        typed_value
      end
    end
    alias :[]= :write_attribute

    # Process the provided attributes casting them to their proper values if a
    # field exists for them on the document. This will be limited to only the
    # attributes provided in the suppied +Hash+ so that no extra nil values get
    # put into the document's attributes.
    #
    # @example Process the attributes.
    #   person.process_attributes(:title => "sir", :age => 40)
    #
    # @param [ Hash ] attrs The attributes to set.
    #
    # @since 2.0.0.rc.7
    def process_attributes(attrs = nil)
      attrs ||= {}
      if !attrs.empty?
        attrs.each_pair do |key, value|
          process_attribute(key, value)
        end
      end
      # context?
      # yield self if block_given?
    end

    # If the attribute is dynamic, add a field for it with a type of object
    # and then either way set the value.
    #
    # @example Process the attribute.
    #   document.process_attribute(name, value)
    #
    # @param [ Symbol ] name The name of the field.
    # @param [ Object ] value The value of the field.
    #
    # @since 2.0.0.rc.7
    def process_attribute(name, value)
      responds = respond_to?("#{name}=", true)
      raise TinyDyno::Errors::UnknownAttribute.new(self.class, name) unless responds
      send("#{name}=", value)
    end

    # Return the typecasted value for a field.
    # Based on the field option, type
    # which is mandatory
    #
    # @example Get the value typecasted.
    #   person.typed_value_for(:title, :sir)
    #
    # @param [ String, Symbol ] key The field name.
    # @param [ Object ] value The uncast value.
    #
    # @return [ Object ] The cast value.
    #
    # @since 1.0.0
    def typed_value_for(key, value)
      # raise MissingAttributeError if fields[key].nil? and hash_keys.find_index { |a| a[:attr] == key }.nil?
      raise MissingAttributeError if fields[key].nil?
      typed_class = self.fields[key].options[:type]
      if typed_class == String
        value.blank? ? nil : value.to_s
      elsif (typed_class == Integer or typed_class == Fixnum )
        value.to_i
      else
        value
      end
    end

  end
end