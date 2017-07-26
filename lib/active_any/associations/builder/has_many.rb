# frozen_string_literal: true

module ActiveAny::Associations::Builder
  class HasMany < SingularAssociation
    def self.macro
      :has_many
    end
  end
end
