# frozen_string_literal: true

module ActiveAny
  class BasicAdapter < AbstractAdapter
    def query(where_clause, limit_value = nil, group_values = [], order_values = [])
      records = select_handler(@klass.data, where_clause)
      records = group_handler(records, group_values)
      records = limit_handler(records, limit_value)
      records = order_handler(records, order_values)
      records
    end

    def select_handler(records, where_clause)
      records.select do |record|
        where_clause.all? do |condition|
          condition.evaluate(self, record)
        end
      end
    end

    def limit_handler(records, limit_value)
      limit_value ? records.take(limit_value) : records
    end

    def order_handler(records, order_values)
      records.sort do |a, b|
        blocks = order_values.map do |order_value|
          build_order_proc(a, b, order_value)
        end
        blocks.map(&:call).find(&:nonzero?) || 0
      end
    end

    private

    def build_order_proc(_a, _b, _order_value)
      raise NotImplementedError.new, "#{self.class.name} can not handle for order"
    end
  end
end
