# frozen_string_literal: true

module ActiveAny
  module Reflection
    class HasOneReflection < AssociationReflection
      def association_class
        Associations::HasOneAssociation
      end

      def macro
        :has_one
      end

      def has_one?
        true
      end

      def collection?
        false
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
