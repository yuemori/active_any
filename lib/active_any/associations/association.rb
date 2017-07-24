# frozen_string_literal: true

module ActiveAny
  module Associations
    class Association
      attr_reader :loaded, :reflection, :target, :owner

      def initialize(owner, reflection)
        @owner = owner
        @reflection = reflection

        reset
        reset_scope
      end

      def reader
        # TODO: implement
        # reload if stale_target?

        @proxy ||= CollectionProxy.create(owner, self)
        @proxy.reset_scope
      end

      def writer(_records)
        raise NotImplementedError.new, 'writer is unimplemented'
      end

      def scope
        target_scope.merge!(association_scope)
      end

      def target_scope
        AssociationRelation.create(klass, self).merge!(klass.all)
      end

      def association_scope
        @association_scope ||= klass ? AssociationScope.scope(self) : nil
      end

      def reload
        reset
        reset_scope
        load_target
        self unless target.nil?
      end

      def klass
        reflection.klass
      end

      def load_target
        @target = find_target if find_target?

        loaded! unless loaded?
        target
        # TODO: implement
        # rescue ActiveRecord::RecordNotFound
        #   reset
      end

      def reset
        @loaded = false
        @stale_target = nil
      end

      def reset_scope
        @association_scope = nil
      end

      def loaded?
        @loaded
      end

      def find_target
        raise NotImplementedError
      end

      def loaded!
        @loaded = true
      end

      def target=(target)
        @target = target
        loaded!
      end

      private

      def find_target?
        !loaded? && klass
      end
    end
  end
end
