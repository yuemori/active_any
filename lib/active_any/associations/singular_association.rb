# frozen_string_literal: true

module ActiveAny
  module Associations
    class SingularAssociation < Association
      def find_target
        scope.first
      end

      def reader
        reload unless loaded?

        target
      end
    end
  end
end
