require 'active_support/hash_with_indifferent_access'
require 'active_support/core_ext/object/duplicable'
require 'active_support/core_ext/string/filters'

module ActiveModel

  module Dirty
    extend ActiveSupport::Concern
    include ActiveModel::AttributeMethods

    # Handle <tt>*_will_change!</tt> for +method_missing+.
    def attribute_will_change!(attr)
      return if attribute_changed?(attr)

      begin
        value = __send__(attr)
        value = value.duplicable? ? value.clone : value
      rescue TypeError, NoMethodError,ArgumentError
      end

      set_attribute_was(attr, value)
    end

  end
end
