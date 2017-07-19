# frozen_string_literal: true

class Adapter
  def initialize(klass)
    @klass = klass
  end

  def query(where_clause, limit_value)
    records = @klass.load

    records = records.select do |record|
      where_clause.all? do |condition|
        condition.match?(record)
      end
    end

    limit_value ? records.take(limit_value) : records
  end
end
