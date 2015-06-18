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

      end

    end
  end
end

::Integer.__send__(:include, TinyDyno::Extensions::Integer)
::Integer.extend(TinyDyno::Extensions::Integer::ClassMethods)
