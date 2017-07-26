# frozen_string_literal: true

module ActiveAny::Associations::Builder
  class HasOne < SingularAssociation
    def self.macro
      :has_one
    end

    def self.valid_options(options)
      valid = super
      # valid += %i[through source source_type] if options[:through]
      valid
    end
  end
end
