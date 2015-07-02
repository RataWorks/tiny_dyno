# encoding: utf-8
module TinyDyno
  module Errors

    # This error is raised when trying to set a value in Mongoid that is not
    # already set with dynamic attributes or the field is not defined.
    class InvalidHashKey < TinyDynoError

      # Create the new error.
      #
      # @example Instantiate the error.
      #   UnknownAttribute.new(Person, "gender")
      #
      # @param [ Class ] klass The model class.
      # @param [ String, Symbol ] name The name of the attribute.
      #
      # @since 3.0.0
      def initialize(klass:, name:)
        super(
            compose_message("invalid_hash_key", { klass: klass.name, name: name })
        )
      end
    end
  end
end

# encoding: utf-8
module TinyDyno
  module Errors

    # This error is raised when trying to set a value in Mongoid that is not
    # already set with dynamic attributes or the field is not defined.
    class MissingHashKey < TinyDynoError

      # Create the new error.
      #
      # @example Instantiate the error.
      #   UnknownAttribute.new(Person, "gender")
      #
      # @param [ Class ] klass The model class.
      # @param [ String, Symbol ] name The name of the attribute.
      #
      # @since 3.0.0
      def initialize(klass:)
        super(
            compose_message("no hash key specified", { klass: klass.name })
        )
      end
    end
  end
end

# encoding: utf-8
module TinyDyno
  module Errors

    # This error is raised, when a query is performed with fields specified
    # that are not HashKeys, which would result in a table scan
    class HashKeyOnly < TinyDynoError

      # Create the new error.
      #
      # @example Instantiate the error.
      #   HashKeysOnly.new(Person, "gender")
      #
      # @param [ Class ] klass The model class.
      # @param [ String, Symbol ] name The name of the attribute.
      #
      # @since 3.0.0
      def initialize(klass:, name:)
        super(
            compose_message("only search for hash keys", { klass: klass.name, name: name })
        )
      end
    end
  end
end

# encoding: utf-8
module TinyDyno
  module Errors

    # This error is raised, when a query is performed with fields specified
    # that are not HashKeys, which would result in a table scan
    class OnlyOneHashKeyPermitted < TinyDynoError

      # Create the new error.
      #
      # @example Instantiate the error.
      #   OnlyOneHashKeyPermitted.new(Person, "gender")
      #
      # @param [ Class ] klass The model class.
      # @param [ String, Symbol ] name The name of the attribute.
      #
      # @since 3.0.0
      def initialize(klass:, name:)
        super(
            compose_message("you can only define one hash_key", { klass: klass.name, name: name })
        )
      end
    end
  end
end

