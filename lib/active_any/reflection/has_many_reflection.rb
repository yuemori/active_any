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

      private

      def join_pk
        foreign_key
      end

      def join_fk
        record_class_primary_key
      end
    end
  end
end
