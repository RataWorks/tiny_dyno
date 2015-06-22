module TinyDyno
  module RangeAttributes
    extend ActiveSupport::Concern

    attr_reader :range_attributes

    included do
      class_attribute :range_attributes

      self.range_attributes = []

    end

  end
end
