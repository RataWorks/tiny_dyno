require 'tiny_dyno/fields/standard'
require 'tiny_dyno/fields/range_key'

module TinyDyno
  module Fields
    extend ActiveSupport::Concern

    included do
      class_attribute :fields

      self.fields = {}

    end

    class << self

      # Stores the provided block to be run when the option name specified is
      # defined on a field.
      #
      # No assumptions are made about what sort of work the handler might
      # perform, so it will always be called if the `option_name` key is
      # provided in the field definition -- even if it is false or nil.
      #
      # @example
      #   TinyDyno::Fields.option :required do |model, field, value|
      #     model.validates_presence_of field if value
      #   end
      #
      # @param [ Symbol ] option_name the option name to match against
      # @param [ Proc ] block the handler to execute when the option is
      #   provided.
      #
      # @since 2.1.0

      def option(option_name, &block)
        options[option_name] = block
      end

      # Return a map of custom option names to their handlers.
      #
      # @example
      #   TinyDyno::Fields.options
      #   # => { :required => #<Proc:0x00000100976b38> }
      #
      # @return [ Hash ] the option map
      #
      # @since 2.1.0
      def options
        @options ||= {}
      end
    end

    # Get the name of the provided field as it is stored in the database.
    # Used in determining if the field is aliased or not.
    #
    # @example Get the database field name.
    #   model.database_field_name(:authorization)
    #
    # @param [ String, Symbol ] name The name to get.
    #
    # @return [ String ] The name of the field as it's stored in the db.
    #
    # @since 3.0.7
    def database_field_name(name)
      self.class.database_field_name(name)
    end

    module ClassMethods

      # Returns an array of names for the attributes available on this object.
      #
      # Provides the field names in an ORM-agnostic way. Rails v3.1+ uses this
      # method to automatically wrap params in JSON requests.
      #
      # @example Get the field names
      #   Model.attribute_names
      #
      # @return [ Array<String> ] The field names
      #
      # @since 3.0.0
      def attribute_names
        fields.keys
      end

      # Get the name of the provided field as it is stored in the database.
      # Used in determining if the field is aliased or not.
      #
      # @example Get the database field name.
      #   Model.database_field_name(:authorization)
      #
      # @param [ String, Symbol ] name The name to get.
      #
      # @return [ String ] The name of the field as it's stored in the db.
      #
      # @since 3.0.7
      def database_field_name(name)
        return nil unless name
        normalized = name.to_s
      end

      # Defines all the fields that are accessible on the Document
      # For each field that is defined, a getter and setter will be
      # added as an instance method to the Document.
      #
      # @example Define a field.
      #   field :score, :type => Integer, :default => 0
      #
      # @param [ Symbol ] name The name of the field.
      # @param [ Hash ] options The options to pass to the field.
      #
      # @option options [ Class ] :type The type of the field.
      # @option options [ String ] :label The label for the field.
      # @option options [ Object, Proc ] :default The field's default
      #
      # @return [ Field ] The generated field
      def field(name, options = {})
        named = name.to_s
        added = add_field(named, options)
        added
      end

      protected

      # Define a field attribute for the +Document+.
      #
      # @example Set the field.
      #   Person.add_field(:name, :default => "Test")
      #
      # @param [ Symbol ] name The name of the field.
      # @param [ Hash ] options The hash of options.
      def add_field(name, options = {})
        field = field_for(name, options)
        fields[name] = field
        create_accessors(name, name, options)
        process_options(field)
        field
      end

      # Run through all custom options stored in TinyDyno::Fields.options and
      # execute the handler if the option is provided.
      #
      # @example
      #   TinyDyno::Fields.option :custom do
      #     puts "called"
      #   end
      #
      #   field = TinyDyno::Fields.new(:test, :custom => true)
      #   Person.process_options(field)
      #   # => "called"
      #
      # @param [ Field ] field the field to process
      def process_options(field)
        field_options = field.options
        Fields.options.each_pair do |option_name, handler|
          if field_options.key?(option_name)
            handler.call(self, field, field_options[option_name])
          end
        end
      end

      def field_for(name, options)
        opts = options.merge(klass: self)
        if opts.has_key?(:range_key) && opts[:range_key] == true
          named = name.to_s
          ad = build_attribute_definition(named,opts[:type])
          attribute_definitions << ad
          ks = { attribute_name: named, key_type: 'RANGE' }
          key_schema << ks
          self.range_key = ks.merge(ad)
          Fields::RangeKey.new(name, opts)
        else
          Fields::Standard.new(name, opts)
        end
      end

      # Create the field accessors.
      #
      # @example Generate the accessors.
      #   Person.create_accessors(:name, "name")
      #   person.name #=> returns the field
      #   person.name = "" #=> sets the field
      #   person.name? #=> Is the field present?
      #   person.name_before_type_cast #=> returns the field before type cast
      #
      # @param [ Symbol ] name The name of the field.
      # @param [ Symbol ] meth The name of the accessor.
      # @param [ Hash ] options The options.
      #
      # @since 2.0.0
      def create_accessors(name, meth, options = {})
        field = fields[name]

        create_field_getter(name, meth, field)
        create_field_setter(name, meth, field)
        create_field_check(name, meth)

      end

      # Create the getter method for the provided field.
      #
      # @example Create the getter.
      #   Model.create_field_getter("name", "name", field)
      #
      # @param [ String ] name The name of the attribute.
      # @param [ String ] meth The name of the method.
      # @param [ Field ] field The field.
      def create_field_getter(name, meth, field)
        generated_methods.module_eval do
          re_define_method(meth) do
            raw = read_attribute(name)
            value = typed_value_for(name, raw)
            attribute_will_change!(value)
            value
          end
        end
      end

      # Create the getter_before_type_cast method for the provided field. If
      # the attribute has been assigned, return the attribute before it was
      # type cast. Otherwise, delegate to the getter.
      #
      # @example Create the getter_before_type_cast.
      # Model.create_field_getter_before_type_cast("name", "name")
      #
      # @param [ String ] name The name of the attribute.
      # @param [ String ] meth The name of the method.
      #
      def create_field_getter_before_type_cast(name, meth)
        generated_methods.module_eval do
          re_define_method("#{meth}_before_type_cast") do
            if has_attribute_before_type_cast?(name)
              read_attribute_before_type_cast(name)
            else
              send meth
            end
          end
        end
      end

      # Create the setter method for the provided field.
      #
      # @example Create the setter.
      #   Model.create_field_setter("name", "name")
      #
      # @param [ String ] name The name of the attribute.
      # @param [ String ] meth The name of the method.
      # @param [ Field ] field The field.
      def create_field_setter(name, meth, field)
        generated_methods.module_eval do
          re_define_method("#{meth}=") do |value|
            typed_value = TinyDyno::Adapter.simple_attribute(field_type: field.options[:type], value: value)
            write_attribute(name, typed_value)
          end
        end
      end

      # Create the check method for the provided field.
      #
      # @example Create the check.
      #   Model.create_field_check("name", "name")
      #
      # @param [ String ] name The name of the attribute.
      # @param [ String ] meth The name of the method.
      #
      # @since 2.4.0
      def create_field_check(name, meth)
        generated_methods.module_eval do
          re_define_method("#{meth}?") do
            attr = read_attribute(name)
            attr == true || attr.present?
          end
        end
      end

      # Include the field methods as a module, so they can be overridden.
      #
      # @example Include the fields.
      #   Person.generated_methods
      #
      # @return [ Module ] The module of generated methods.
      #
      # @since 2.0.0
      def generated_methods
        @generated_methods ||= begin
          mod = Module.new
          include(mod)
          mod
        end
      end

    end

  end
end