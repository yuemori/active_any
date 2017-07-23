# frozen_string_literal: true

module ActiveAny
  module AttributeAssignment
    def init_internals(attributes = {})
      assign_attributes(attributes) if attributes.present?
      super
    end

    def assign_attributes(data)
      data.each do |key, value|
        public_send("#{key}=", value)
      end
    end
  end
end
