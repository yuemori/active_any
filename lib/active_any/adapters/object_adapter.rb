# frozen_string_literal: true

module ActiveAny
  class ObjectAdapter < AbstractAdapter
    def query(where_clause: Relation::WhereClause.empty, order_clause: Relation::OrderClause.empty, limit_value: nil, group_values: [])
      records = where_handler(@klass.data, where_clause)
      records = group_handler(records, group_values)
      records = limit_handler(records, limit_value)
      records = order_handler(records, order_clause)
      records
    end

    def where_handler(records, where_clause)
      records.select do |record|
        where_clause.all? do |condition|
          condition.evaluate(self, record)
        end
      end
    end

    def limit_handler(records, limit_value)
      limit_value ? records.take(limit_value) : records
    end

    def order_handler(records, order_clause)
      ordered_records = order_clause.empty? ? records : sort_by_order_clause(records, order_clause)
      order_clause.reverse? ? ordered_records.reverse : ordered_records
    end

    def base_handler(record, key, value)
      record.send(key) == value
    end

    def regexp_handler(record, key, regexp)
      regexp.match? record.send(key)
    end

    def range_handler(record, key, range)
      range.include? record.send(key)
    end

    def array_handler(record, key, array)
      array.include? record.send(key)
    end

    def group_handler(records, group_values)
      return records if group_values.empty?

      records.uniq do |record|
        group_values.map { |method| record.send(method) }
      end
    end

    private

    def build_order_proc(a, b, order_value)
      case order_value.sort_type
      when :asc then proc { a.send(order_value.key) <=> b.send(order_value.key) }
      when :desc then proc { -(a.send(order_value.key) <=> b.send(order_value.key)) }
      else
        raise ArgumentError, "#{order_value.sort_type} is not supported"
      end
    end

    def sort_by_order_clause(records, order_clause)
      records.sort do |a, b|
        blocks = order_clause.order_values.map do |order_value|
          build_order_proc(a, b, order_value)
        end
        blocks.map(&:call).find(&:nonzero?) || 0
      end
    end
  end
end
