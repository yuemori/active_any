# frozen_string_literal: true

module ActiveAny
  class BasicAdapter < AbstractAdapter
    def query(where_clause, limit_value = nil, group_clause = [])
      records = @klass.data

      records = records.select do |record|
        where_clause.all? do |condition|
          condition.evaluate(self, record)
        end
      end

      records = group_handler(records, group_clause) if group_clause
      limit_value ? records.take(limit_value) : records
    end
  end
end
