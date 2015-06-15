# encoding: utf-8
module TinyDyno
  module Extensions
    module Object

      # Evolve a plain object into an object id.
      #
      # @example Evolve the object.
      #   object.__evolve_object_id__
      #
      # @return [ Object ] self.
      #
      # @since 3.0.0
      def __evolve_object_id__
        self
      end
      alias :__mongoize_object_id__ :__evolve_object_id__

      # Convert the object to args for a find query.
      #
      # @example Convert the object to args.
      #   object.__find_args__
      #
      # @return [ Object ] self.
      #
      # @since 3.0.0
      def __find_args__
        self
      end

      # Mongoize a plain object into a time.
      #
      # @example Mongoize the object.
      #   object.__mongoize_time__
      #
      # @return [ Object ] self.
      #
      # @since 3.0.0
      def __mongoize_time__
        self
      end

      # Try to form a setter from this object.
      #
      # @example Try to form a setter.
      #   object.__setter__
      #
      # @return [ String ] The object as a string plus =.
      #
      # @since 3.1.0
      def __setter__
        "#{self}="
      end

      # Get the value of the object as a mongo friendy sort value.
      #
      # @example Get the object as sort criteria.
      #   object.__sortable__
      #
      # @return [ Object ] self.
      #
      # @since 3.0.0
      def __sortable__
        self
      end

      # Conversion of an object to an $inc-able value.
      #
      # @example Convert the object.
      #   1.__to_inc__
      #
      # @return [ Object ] The object.
      #
      # @since 3.0.3
      def __to_inc__
        self
      end

      # Check if the object is part of a blank relation criteria.
      #
      # @example Is the object blank criteria?
      #   "".blank_criteria?
      #
      # @return [ true, false ] If the object is blank criteria.
      #
      # @since 3.1.0
      def blank_criteria?
        false
      end

      # Do or do not, there is no try. -- Yoda.
      #
      # @example Do or do not.
      #   object.do_or_do_not(:use, "The Force")
      #
      # @param [ String, Symbol ] name The method name.
      # @param [ Array ] *args The arguments.
      #
      # @return [ Object, nil ] The result of the method call or nil if the
      #   method does not exist.
      #
      # @since 2.0.0.rc.1
      def do_or_do_not(name, *args)
        send(name, *args) if name && respond_to?(name)
      end

      # Get the value for an instance variable or false if it doesn't exist.
      #
      # @example Get the value for an instance var.
      #   document.ivar("person")
      #
      # @param [ String ] name The name of the variable.
      #
      # @return [ Object, false ] The value or false.
      #
      # @since 2.0.0.rc.1
      def ivar(name)
        var_name = "@_#{name}"
        if instance_variable_defined?(var_name)
          return instance_variable_get(var_name)
        else
          false
        end
      end

      # Turn the object from the ruby type we deal with to a Mongo friendly
      # type.
      #
      # @example Mongoize the object.
      #   object.mongoize
      #
      # @return [ Object ] The object.
      #
      # @since 3.0.0
      def to_dyno_type(object)
        p "caller: #{ caller[0]}"
        self
      end

      # Is the object multi args.
      #
      # @example Is the object multi args?
      #   object.multi_arged?
      #
      # @return [ false ] false.
      #
      # @since 3.0.0
      def multi_arged?
        false
      end

      # Is the object a number?
      #
      # @example Is the object a number?.
      #   object.numeric?
      #
      # @return [ false ] Always false.
      #
      # @since 3.0.0
      def numeric?
        false
      end

      # Remove the instance variable for the provided name.
      #
      # @example Remove the instance variable
      #   document.remove_ivar("person")
      #
      # @param [ String ] name The name of the variable.
      #
      # @return [ true, false ] If the variable was defined.
      #
      # @since 2.1.0
      def remove_ivar(name)
        if instance_variable_defined?("@_#{name}")
          return remove_instance_variable("@_#{name}")
        else
          false
        end
      end

      # Is the object's size changable? Only returns true for arrays and hashes
      # currently.
      #
      # @example Is the object resizable?
      #   object.resizable?
      #
      # @return [ false ] false.
      #
      # @since 3.0.0
      def resizable?
        false
      end

      # Get the substitutable version of an object.
      #
      # @example Get the substitutable.
      #   object.substitutable
      #
      # @return [ Object ] self.
      #
      # @since 2.0.0
      def substitutable
        self
      end

      # You must unlearn what you have learned. -- Yoda
      #
      # @example You must perform this execution.
      #   object.you_must(:use, "The Force")
      #
      # @param [ String, Symbol ] name The method name.
      # @param [ Array ] *args The arguments.
      #
      # @return [ Object, nil ] The result of the method call or nil if the
      #   method does not exist. Nil if the object is frozen.
      #
      # @since 2.2.1
      def you_must(name, *args)
        frozen? ? nil : do_or_do_not(name, *args)
      end

      module ClassMethods

        # Convert the object from its mongo friendly ruby type to this type.
        #
        # @example Demongoize the object.
        #   Object.demongoize(object)
        #
        # @param [ Object ] object The object to demongoize.
        #
        # @return [ Object ] The object.
        #
        # @since 3.0.0
        def from_dyno_type(object)
          object
        end

        # Turn the object from the ruby type we deal with to a Mongo friendly
        # type.
        #
        # @example Mongoize the object.
        #   Object.mongoize("123.11")
        #
        # @param [ Object ] object The object to mongoize.
        #
        # @return [ Object ] The object mongoized.
        #
        # @since 3.0.0
        def to_dyno_type(object)
          object.from_dyno_type
        end
        def __deep_copy__; self; end
      end
    end
  end
end

::Object.__send__(:include, TinyDyno::Extensions::Object)
::Object.extend(TinyDyno::Extensions::Object::ClassMethods)
