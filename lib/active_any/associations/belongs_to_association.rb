# frozen_string_literal: true

module ActiveAny
  module Associations
    class BelongsToAssociation < Association
      def reader
        reload unless loaded?

        target
      end

      def writer(_records)
        raise NotImplementedError.new, 'writer is unimplemented'
      end

      def find_target
        scope.first
      end
    end
  end
end
