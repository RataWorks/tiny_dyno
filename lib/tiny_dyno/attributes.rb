# encoding: utf-8
require 'active_model/attribute_methods'
require 'tiny_dyno/attributes/processing'
require 'tiny_dyno/attributes/readonly'

module TinyDyno

  # This module contains the logic for handling the internal attributes hash,
  # and how to get and set values.
  module Attributes
    extend ActiveSupport::Concern

    include Processing
    include Readonly

    attr_reader :attributes

    # # Determine if an attribute is present.
    #
    # @example Is the attribute present?
    #   person.attribute_present?("title")
    #
    # @param [ String, Symbol ] name The name of the attribute.
    #
    #
    # @return [ true, false ] True if present, false if not.
    #
    # @since 1.0.0
    def attribute_present?(name)
      attribute = read_attribute(name)
      !attribute.blank? || attribute == false
    rescue ActiveModel::MissingAttributeError
      false
    end

    # Get the attributes that have not been cast.
    #
    # @example Get the attributes before type cast.
    # document.attributes_before_type_cast
    #
    # @return [ Hash ] The uncast attributes.
    #
    # @since 3.1.0
    def attributes_before_type_cast
      @attributes_before_type_cast ||= {}
    end

    # Does the document have the provided attribute?
    #
    # @example Does the document have the attribute?
    #   model.has_attribute?(:name)
    #
    # @param [ String, Symbol ] name The name of the attribute.
    #
    # @return [ true, false ] If the key is present in the attributes.
    #
    # @since 3.0.0
    def has_attribute?(name)
      attributes.key?(name.to_s)
    end

    # Does the document have the provided attribute before it was assigned
    # and type cast?
    #
    # @example Does the document have the attribute before it was assigned?
    #   model.has_attribute_before_type_cast?(:name)
    #
    # @param [ String, Symbol ] name The name of the attribute.
    #
    # @return [ true, false ] If the key is present in the
    #   attributes_before_type_cast.
    #
    # @since 3.1.0
    def has_attribute_before_type_cast?(name)
      attributes_before_type_cast.key?(name.to_s)
    end

    # Read a value from the document attributes. If the value does not exist
    # it will return nil.
    #
    # @example Read an attribute.
    #   person.read_attribute(:title)
    #
    # @example Read an attribute (alternate syntax.)
    #   person[:title]
    #
    # @param [ String, Symbol ] name The name of the attribute to get.
    #
    # @return [ Object ] The value of the attribute.
    #
    # @since 1.0.0
    def read_attribute(name)
      normalized = database_field_name(name.to_s)
      if attribute_missing?(normalized)
        raise ActiveModel::MissingAttributeError, "Missing attribute: '#{name}'."
      end
      attributes[normalized]
    end
    alias :[] :read_attribute

    # Read a value from the attributes before type cast. If the value has not
    # yet been assigned then this will return the attribute's existing value
    # using read_attribute.
    #
    # @example Read an attribute before type cast.
    #   person.read_attribute_before_type_cast(:price)
    #
    # @param [ String, Symbol ] name The name of the attribute to get.
    #
    # @return [ Object ] The value of the attribute before type cast, if
    #   available. Otherwise, the value of the attribute.
    #
    # @since 3.1.0
    def read_attribute_before_type_cast(name)
      attr = name.to_s
      if attributes_before_type_cast.key?(attr)
        attributes_before_type_cast[attr]
      else
        read_attribute(attr)
      end
    end
    # # Remove a value from the +Document+ attributes. If the value does not exist
    # # it will fail gracefully.
    # #
    # # @example Remove the attribute.
    # #   person.remove_attribute(:title)
    # #
    # # @param [ String, Symbol ] name The name of the attribute to remove.
    # #
    # # @raise [ Errors::ReadonlyAttribute ] If the field cannot be removed due
    # #   to being flagged as reaodnly.
    # #
    # # @since 1.0.0
    # def remove_attribute(name)
    #   access = name.to_s
    #   unless attribute_writable?(name)
    #     raise Errors::ReadonlyAttribute.new(name, :nil)
    #   end
    #   attribute_will_change!(access)
    #   delayed_atomic_unsets[atomic_attribute_name(access)] = [] unless new_record?
    #   attributes.delete(access)
    # end

    # Write a single attribute to the document attribute hash. This will
    # also fire the before and after update callbacks, and perform any
    # necessary typecasting.
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
      attributes_before_type_cast[name.to_s] = value
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

    # Al lows you to set all the attributes for a particular mass-assignment security role
    # by passing in a hash of attributes with keys matching the attribute names
    # (which again matches the column names)  and the role name using the :as option.
    # To bypass mass-assignment security you can use the :without_protection => true option.
    #
    # @example Assign the attributes.
    #   person.assign_attributes(:title => "Mr.")
    #
    # @example Assign the attributes (with a role).
    #   person.assign_attributes({ :title => "Mr." }, :as => :admin)
    #
    # @param [ Hash ] attrs The new attributes to set.
    #
    # @since 2.2.1
    def assign_attributes(attrs = nil)
      process_attributes(attrs)
    end

    # Writes the supplied attributes hash to the document. This will only
    # overwrite existing attributes if they are present in the new +Hash+, all
    # others will be preserved.
    #
    # @example Write the attributes.
    #   person.write_attributes(:title => "Mr.")
    #
    # @example Write the attributes (alternate syntax.)
    #   person.attributes = { :title => "Mr." }
    #
    # @param [ Hash ] attrs The new attributes to set.
    # @param [ Boolean ] guard_protected_attributes False to skip mass assignment protection.
    #
    # @since 1.0.0
    def write_attributes(attrs = nil)
      assign_attributes(attrs)
    end
    alias :attributes= :write_attributes

    # Determine if the attribute is missing from the document, due to loading
    # it from the database with missing fields.
    #
    # @example Is the attribute missing?
    #   document.attribute_missing?("test")
    #
    # @param [ String ] name The name of the attribute.
    #
    # @return [ true, false ] If the attribute is missing.
    #
    # @since 4.0.0
    def attribute_missing?(name)
      selection = __selected_fields
      return false unless selection
      field = fields[name]
      (selection.values.first == 0 && selection_excluded?(name, selection, field)) ||
          (selection.values.first == 1 && !selection_included?(name, selection, field))
    end

    private

    def selection_excluded?(name, selection, field)
      if field && field.localized?
        selection["#{name}.#{::I18n.locale}"] == 0
      else
        selection[name] == 0
      end
    end

    def selection_included?(name, selection, field)
      if field && field.localized?
        selection.key?("#{name}.#{::I18n.locale}")
      else
        selection.key?(name)
      end
    end

    # Return the typecasted value for a field.
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
      raise MissingAttributeError if self.fields[key].nil?
      typed_class = self.fields[key].options[:type]
      if typed_class == String
        value.blank? ? nil : value.to_s
      elsif (typed_class == Integer or typed_class == Fixnum )
        value.to_i
      else
        value
      end
    end

    # Does the string contain dot syntax for accessing hashes?
    #
    # @api private
    #
    # @example Is the string in dot syntax.
    #   model.hash_dot_syntax?
    #
    # @return [ true, false ] If the string contains a "."
    #
    # @since 3.0.15
    def hash_dot_syntax?(string)
      string.include?(".".freeze)
    end

    # Get the changed attributes for the document.
    # #
    # # @example Get the changed attributes.
    # #   model.changed
    # #
    # # @return [ Array<String> ] The changed attributes.
    # #
    # # @since 2.4.0
    # def changed
    #   changed_attributes.keys.select { |attr| attribute_change(attr) }
    # end
    #
    # # Has the document changed?
    # #
    # # @example Has the document changed?
    # #   model.changed?
    # #
    # # @return [ true, false ] If the document is changed.
    # #
    # # @since 2.4.0
    # def changed?
    #   changes.values.any? { |val| val } || children_changed?
    # end
    #
    # # Get the attribute changes.
    # #
    # # @example Get the attribute changes.
    # #   model.changed_attributes
    # #
    # # @return [ Hash<String, Object> ] The attribute changes.
    # #
    # # @since 2.4.0
    # def changed_attributes
    #   @changed_attributes ||= {}
    # end
    #
    # # Get all the changes for the document.
    # #
    # # @example Get all the changes.
    # #   model.changes
    # #
    # # @return [ Hash<String, Array<Object, Object> ] The changes.
    # #
    # # @since 2.4.0
    # def changes
    #   these_changes = {}
    #   changed.each do |attr|
    #     change = attribute_change(attr)
    #     these_changes[attr] = change if change
    #   end
    #   these_changes
    # end
    #
    # # Gets all the new values for each of the changed fields, to be passed to
    # # a MongoDB $set modifier.
    # #
    # # @example Get the setters for the atomic updates.
    # #   person = SmallPerson.new(:title => "Sir")
    # #   person.title = "Madam"
    # #   person.setters # returns { "title" => "Madam" }
    # #
    # # @return [ Hash ] A +Hash+ of atomic setters.
    # #
    # # @since 2.0.0
    # def setters
    #   mods = {}
    #   changes.each_pair do |name, changes|
    #     if changes
    #       old, new = changes
    #       field = fields[name]
    #       key = name
    #       mods[key] = new unless atomic_unsets.include?(key)
    #     end
    #   end
    #   mods
    # end

    private

    # # Flag an attribute as going to change.
    # #
    # # @example Flag the attribute.
    # #   model.attribute_will_change!("name")
    # #
    # # @param [ String ] attr The name of the attribute.
    # #
    # # @return [ Object ] The old value.
    # #
    # # @since 2.3.0
    # def attribute_will_change!(attr)
    #   unless changed_attributes.key?(attr)
    #     read_attr =  read_attribute(attr)
    #     if read_attr.nil?
    #       changed_attributes[attr] = nil
    #     else
    #       changed_attributes[attr] = read_attribute(attr).__deep_copy__
    #     end
    #   end
    # end

    module ClassMethods

      private

      # # Generate all the dirty methods needed for the attribute.
      # #
      # # @example Generate the dirty methods.
      # #   Model.create_dirty_methods("name", "name")
      # #
      # # @param [ String ] name The name of the field.
      # # @param [ String ] name The name of the accessor.
      # #
      # # @return [ Module ] The fields module.
      # #
      # # @since 2.4.0
      # def create_dirty_methods(name, meth)
      #   create_dirty_change_accessor(name, meth)
      #   create_dirty_change_check(name, meth)
      #   create_dirty_change_flag(name, meth)
      #   create_dirty_default_change_check(name, meth)
      #   create_dirty_previous_value_accessor(name, meth)
      #   create_dirty_reset(name, meth)
      # end

      # # Creates the dirty change accessor.
      # #
      # # @example Create the accessor.
      # #   Model.create_dirty_change_accessor("name", "alias")
      # #
      # # @param [ String ] name The attribute name.
      # # @param [ String ] meth The name of the accessor.
      # #
      # # @since 3.0.0
      # def create_dirty_change_accessor(name, meth)
      #   generated_methods.module_eval do
      #     re_define_method("#{meth}_change") do
      #       attribute_change(name)
      #     end
      #   end
      # end

      # # Creates the dirty change check.
      # #
      # # @example Create the check.
      # #   Model.create_dirty_change_check("name", "alias")
      # #
      # # @param [ String ] name The attribute name.
      # # @param [ String ] meth The name of the accessor.
      # #
      # # @since 3.0.0
      # def create_dirty_change_check(name, meth)
      #   generated_methods.module_eval do
      #     re_define_method("#{meth}_changed?") do
      #       attribute_changed?(name)
      #     end
      #   end
      # end

      # # Creates the dirty default change check.
      # #
      # # @example Create the check.
      # #   Model.create_dirty_default_change_check("name", "alias")
      # #
      # # @param [ String ] name The attribute name.
      # # @param [ String ] meth The name of the accessor.
      # #
      # # @since 3.0.0
      # def create_dirty_default_change_check(name, meth)
      #   generated_methods.module_eval do
      #     re_define_method("#{meth}_changed_from_default?") do
      #       attribute_changed_from_default?(name)
      #     end
      #   end
      # end

      # # Creates the dirty change previous value accessor.
      # #
      # # @example Create the accessor.
      # #   Model.create_dirty_previous_value_accessor("name", "alias")
      # #
      # # @param [ String ] name The attribute name.
      # # @param [ String ] meth The name of the accessor.
      # #
      # # @since 3.0.0
      # def create_dirty_previous_value_accessor(name, meth)
      #   generated_methods.module_eval do
      #     re_define_method("#{meth}_was") do
      #       attribute_was(name)
      #     end
      #   end
      # end

      # # Creates the dirty change flag.
      # #
      # # @example Create the flag.
      # #   Model.create_dirty_change_flag("name", "alias")
      # #
      # # @param [ String ] name The attribute name.
      # # @param [ String ] meth The name of the accessor.
      # #
      # # @since 3.0.0
      # def create_dirty_change_flag(name, meth)
      #   generated_methods.module_eval do
      #     re_define_method("#{meth}_will_change!") do
      #       attribute_will_change!(name)
      #     end
      #   end
      # end

      # # Creates the dirty change reset.
      # #
      # # @example Create the reset.
      # #   Model.create_dirty_reset("name", "alias")
      # #
      # # @param [ String ] name The attribute name.
      # # @param [ String ] meth The name of the accessor.
      # #
      # # @since 3.0.0
      # def create_dirty_reset(name, meth)
      #   generated_methods.module_eval do
      #     re_define_method("reset_#{meth}!") do
      #       reset_attribute!(name)
      #     end
      #   end
      # end

    end

  end
end
