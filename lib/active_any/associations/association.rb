# frozen_string_literal: true

module ActiveAny
  module Associations
    class Association
      attr_reader :loaded, :reflection, :target, :owner, :inversed

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
        @inversed = false
      end

      def reset_scope
        @association_scope = nil
      end

      def loaded?
        @loaded
      end

      def find_from_target?
        loaded?
      end

      def find_target
        raise NotImplementedError
      end

      def loaded!
        @loaded = true
        @inversed = false
      end

      def target=(target)
        @target = target
        loaded!
      end

      def set_inverse_instance(record)
        if invertible_for?(record)
          inverse = record.association(inverse_reflection_for(record).name)
          inverse.target = owner
          inverse.inversed = true
        end
        record
      end

      private

      def invertible_for?(record)
        foreign_key_for?(record) && inverse_reflection_for(record)
      end

      def foreign_key_for?(record)
        record.has_attribute?(reflection.foreign_key)
      end

      def find_target?
        !loaded? && klass
      end

      def inverse_reflection_for(_record)
        reflection.inverse_of
      end
    end
  end
end
