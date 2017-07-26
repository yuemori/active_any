# frozen_string_literal: true

module ActiveAny::Associations::Builder
  class SingularAssociation < Association
    def self.valid_options(options)
      super + %i[primary_key]
    end
  end
end
