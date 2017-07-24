# frozen_string_literal: true

module ActiveAny
  module Associations
    class HasManyAssociation < Association
      def reader
        # TODO: implement
        # reload if stale_target?

        @proxy ||= CollectionProxy.create(owner, self)
        @proxy.reset_scope
      end

      def writer(_records)
        raise NotImplementedError.new, 'writer is unimplemented'
      end

      def reset
        super
        @target = []
      end

      def size
        if !find_target? || loaded?
          target.size
        else
          scope.count
        end
      end

      def empty?
        size.zero?
      end

      def include?(record)
        if record.is_a?(klass)
          target.include?(record)
        else
          false
        end
      end

      def find_target
        scope.to_a
      end
    end
  end
end
