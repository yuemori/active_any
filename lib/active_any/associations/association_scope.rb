# frozen_string_literal: true

module ActiveAny
  module Associations
    class AssociationScope
      def self.scope(association)
        INSTANCE.scope(association)
      end

      def self.create
        new
      end

      INSTANCE = create

      def scope(association)
        klass = association.klass
        reflection = association.reflection
        scope = klass.all
        owner = association.owner

        add_constraints(scope, owner, reflection)
      end

      private

      def add_constraints(scope, owner, reflection)
        join_keys = reflection.join_keys
        key = join_keys.key
        value = owner.send(join_keys.foreign_key)
        scope.where(key => value)
      end
    end
  end
end
