# frozen_string_literal: true

module ActiveAny
  module Finders
    extend ActiveSupport::Concern

    module ClassMethods
      delegate :find_by, :limit, :where, :take, to: :all

      def all
        Relation.create(self)
      end

      def find_by_query(where_clause:, limit_value:, group_values:, order_clause:)
        adapter.query(
          where_clause: where_clause,
          limit_value: limit_value,
          group_values: group_values,
          order_clause: order_clause
        )
      end

      def adapter
        raise NotImplementedError
      end
    end
  end
end
