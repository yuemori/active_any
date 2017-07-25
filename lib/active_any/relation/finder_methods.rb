# frozen_string_literal: true

module ActiveAny
  class Relation
    module FinderMethods
      def find_by(condition)
        where(condition).take
      end

      def first(limit = nil)
        if loaded
          limit ? records.first(limit) : records.first
        else
          limit ? spawn.records.first(limit) : spawn.records.first
        end
      end

      def last(limit = nil)
        return find_last(limit) if loaded? || limit_value

        result = limit(limit)
        result.order!(klass.primary_key) if order_clause.empty? && klass.primary_key
        result = result.reverse_order!
        limit ? result.reverse : result.first
      end

      private

      def find_last(limit)
        limit ? records.last(limit) : records.last
      end
    end
  end
end
