# frozen_string_literal: true

module ActiveAny
  module Reflection
    class BelongsToReflection < AssociationReflection
      def association_class
        Associations::BelongsToAssociation
      end

      def macro
        :belongs_to
      end

      def belongs_to?
        true
      end

      private

      def join_pk
        primary_key
      end

      def join_fk
        foreign_key
      end
    end
  end
end
