# frozen_string_literal: true

module ActiveAny
  class HashAdapter < Adapter
    def query(where_clause, limit_value = nil)
      records = @klass.data

      records = records.select do |record|
        where_clause.all? do |condition|
          record[condition.key] == condition.value
        end
      end

      limit_value ? records.take(limit_value) : records
    end
  end
end
