# frozen_string_literal: true

module ActiveAny
  module Reflection
    class HasManyReflection < AssociationReflection
      def association_class
        Associations::HasManyAssociation
      end

      def macro
        :has_many
      end

      def collection?
        true
      end
    end
  end
end
