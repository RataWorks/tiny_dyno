require 'bigdecimal'
require 'stringio'
require 'set'

module TinyDyno
  module Adapter

    class AttributeValue
    # utilize the same type coercions as in the ruby aws-sdk
    # ( https://github.com/aws/aws-sdk-ruby/blob/master/aws-sdk-core/lib/aws-sdk-core/dynamodb/attribute_value.rb )
    # however in a more deterministic fashion
    # the type conversion employed by the simple attribute feature
    # is purely based on the value field
    # tiny_dyno enforces coercion into the designated target data type
    # or raises an error on mismatch

      def initialize
        @marshaler = Marshaler.new
        @unmarshaler = Unmarshaler.new
      end

      def marshal(type:, value:)
        @marshaler.format(type: type, obj: value)
      end

      def unmarshal(value)
        @unmarshaler.format(value)
      end

      class Marshaler

        def format(type: 'auto', obj:)
          return { null: true } if obj.nil?
          type = obj.class.to_s if type == 'auto'
          case type.to_s
            when 'Hash'
              obj.each.with_object(m:{}) do |(key, value), map|
                map[:m][key.to_s] = format(type: value.class, obj: value)
              end
            when 'Array'
              obj.each.with_object(l:[]) do |value, list|
                list[:l] << format(type: value.class, obj: value)
              end
            when 'String' then { s: obj }
            when 'Symbol' then { s: obj.to_s }
            when 'Numeric', 'Fixnum', 'Float', 'Integer', 'BigDecimal' then numeric_format(type.to_s,obj)
            when 'StringIO', 'IO' then { b: obj }
            when 'Set' then format_set(obj)
            when 'TrueClass', 'FalseClass', 'TinyDyno::Boolean'
              # ToDo, how can we initialize a boolean field into a valid state?
              raise TinyDyno::Errors::InvalidValueType.new(klass: self.class, name: type, value: obj) unless [true,false,nil].include?(obj)
              { bool: obj }
            when 'NilClass' then { null: true }
          else
            msg = "unsupported type, expected Hash, Array, Set, String, Numeric, "
            msg << "IO, true, false, or nil, got #{obj.class.name}"
            raise ArgumentError, msg
          end
        end #format

        private

        def numeric_format(type,obj)
          case type
            when 'Fixnum', 'Integer', 'Numeric'
              if obj.class == BigDecimal
                raise TinyDyno::Errors::NotTransparentlyCoercible.new(klass: self.class, name: type, value: obj) unless obj == BigDecimal.new(obj.to_s)
                { n: obj.to_s }
              elsif obj.class == String
                raise TinyDyno::Errors::NotTransparentlyCoercible.new(klass: self.class, name: type, value: obj) unless obj.to_i.to_s == obj
                { n: obj }
              else
                raise TinyDyno::Errors::NotTransparentlyCoercible.new(klass: self.class, name: type, value: obj) unless obj.to_i == obj.to_s.to_i
                { n: obj.to_s }
              end
            when 'Float'
              raise TinyDyno::Errors::InvalidValueType.new(klass: self.class, name: type, value: obj) unless obj.is_a?(Float)
              raise TinyDyno::Errors::NotTransparentlyCoercible.new(klass: self.class, name: type, value: obj) unless obj == obj.to_s.to_f
              { n: obj.to_s }
            when 'BigDecimal'
              raise TinyDyno::Errors::InvalidValueType.new(klass: self.class, name: type, value: obj) unless obj.is_a?(BigDecimal)
              raise TinyDyno::Errors::NotTransparentlyCoercible.new(klass: self.class, name: type, value: obj) unless obj == BigDecimal.new(obj.to_s)
              { n: obj.to_s}
          else
            msg = "unsupported type, expected Fixnum, Integer, Float, BigDecimal "
            raise ArgumentError, msg
          end
        end #numeric_format

        def format_set(set)
          case set.first
            when String, Symbol then { ss: set.map(&:to_s) }
            when Numeric then { ns: set.map(&:to_s) }
            when StringIO, IO then { bs: set.to_a }
            else
              msg = "set types only support String, Numeric, or IO objects"
              raise ArgumentError, msg
          end
        end #format_set

      end #AttributeValue

      class Unmarshaler

        def format(obj)
          type, value = extract_type_and_value(obj)
          case type
            when :m
              value.each.with_object({}) do |(k, v), map|
                map[k] = format(v)
              end
            when :l then value.map { |v| format(v) }
            when :s then value
            when :n
              if value.nil?
                nil
              else
                BigDecimal.new(value)
              end
            when :b then StringIO.new(value)
            when :null then nil
            when :bool then value
            when :ss then Set.new(value)
            when :ns then Set.new(value.map { |n| BigDecimal.new(n) })
            when :bs then Set.new(value.map { |b| StringIO.new(b) })
            else
              raise ArgumentError, "unhandled type #{type.inspect}"
          end
        end

        private

        def extract_type_and_value(obj)
          case obj
            when Hash then obj.to_a.first
            when Struct
              obj.members.each do |key|
                value = obj[key]
                return [key, value] unless value.nil?
              end
            else
              raise ArgumentError, "unhandled type #{obj.inspect}"
          end
        end

      end
    end #class AttributeValue

    extend self

    def aws_attribute(field_type:, value:)
      av = TinyDyno::Adapter::AttributeValue.new
      av.marshal(type: field_type, value: value)
    end

    def doc_attribute(value)
      return nil if value.nil?
      av = TinyDyno::Adapter::AttributeValue.new
      av.unmarshal(value)
    end

    def simple_attribute(field_type:, value:)
      raw_attribute = aws_attribute(field_type: field_type, value: value)

      case field_type.to_s
        when 'Fixnum', 'Integer' then simple_value = doc_attribute(raw_attribute).to_i
        when 'Float' then simple_value = doc_attribute(raw_attribute).to_f
        when 'Numeric', 'String', 'Array', 'Hash', 'TinyDyno::Boolean' then simple_value = doc_attribute(raw_attribute)
      else
        raise ArgumentError, "unhandled type #{ field_type.inspect }"
      end
      simple_value
    end #simple_attribute

  end
end
