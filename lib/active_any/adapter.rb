# frozen_string_literal: true

class Adapter
  def initialize(records)
    @records = records
  end

  def query(where_clause)
    return @records if where_clause.empty?

    @records.select do |record|
      where_clause.all? do |condition|
        condition.match?(record)
      end
    end
  end
end
