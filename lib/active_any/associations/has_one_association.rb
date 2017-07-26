# frozen_string_literal: true

module ActiveAny
  module Associations
    class HasOneAssociation < SingularAssociation
      include ForeignAssociation
    end
  end
end
