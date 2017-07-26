# frozen_string_literal: true

module ActiveAny
  module Associations
    class CollectionProxy < ActiveAny::Relation
      attr_reader :association

      delegate :target, :load_target, :load_target, :loaded?, :find, :concat,
               :size, :empty?, :include?, to: :@association

      def initialize(klass, association)
        @association = association
        super(klass)
      end

      def last(limit = nil)
        load_target if find_from_target?
        super
      end

      def take(limit = nil)
        load_target if find_from_target?
        super
      end

      def scope
        @scope ||= @association.scope
      end

      def ==(other)
        load_target == other
      end

      def to_ary
        load_target.dup
      end
      alias to_a to_ary

      def records
        load_target
      end

      def proxy_association
        @association
      end

      def reset
        proxy_association.reset
        proxy_association.reset_scope
        reset_scope
      end

      def reload
        proxy_association.reload
        reset_scope
      end

      def reset_scope # :nodoc:
        @offsets = {}
        @scope = nil
        self
      end

      private

      def find_from_target?
        @association.find_from_target?
      end
    end
  end
end
