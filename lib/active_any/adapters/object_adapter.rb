# frozen_string_literal: true

module ActiveAny
  class ObjectAdapter < BasicAdapter
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
  end
end
