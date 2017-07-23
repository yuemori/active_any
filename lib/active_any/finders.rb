# frozen_string_literal: true

module ActiveAny
  module Finders
    extend ActiveSupport::Concern

    module ClassMethods
      delegate :find_by, :limit, :where, :take, to: :all

      def all
        Relation.create(self)
      end

      def find_by_query(where_clause, limit_value, group_values, order_values)
        adapter.query(where_clause, limit_value, group_values, order_values)
      end

      def adapter
        raise NotImplementedError
      end
    end
  end
end
