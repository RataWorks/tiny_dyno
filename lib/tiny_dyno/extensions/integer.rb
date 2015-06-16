# encoding: utf-8
module TinyDyno
  module Extensions
    module Integer

      # Returns the integer as a time.
      #
      # @example Convert the integer to a time.
      #   1335532685.__mongoize_time__
      #
      # @return [ Time ] The converted time.
      #
      # @since 3.0.0
      def __to_dyno_time__
        ::Time.at(self)
      end

      # Is the integer a number?
      #
      # @example Is the object a number?.
      #   object.numeric?
      #
      # @return [ true ] Always true.
      #
      # @since 3.0.0
      def numeric?
        true
      end

      module ClassMethods

        # Turn the object from the ruby type we deal with to a Mongo friendly
        # type.
        #
        # @example Mongoize the object.
        #   BigDecimal.mongoize("123.11")
        #
        # @return [ String ] The object mongoized.
        #
        # @since 3.0.0
        def from_dyno(object)
          unless object.blank?
            object.to_i rescue 0
          else
            nil
          end
        end
        alias :to_dyno :from_dyno
      end
    end
  end
end

::Integer.__send__(:include, TinyDyno::Extensions::Integer)
::Integer.extend(TinyDyno::Extensions::Integer::ClassMethods)
