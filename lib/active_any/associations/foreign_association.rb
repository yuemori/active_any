# frozen_string_literal: true

module ActiveAny::Associations
  module ForeignAssociation
    def foreign_key_present?
      if reflection.klass.primary_key
        owner.attribute_present?(reflection.record_class_primary_key)
      else
        false
      end
    end
  end
end
