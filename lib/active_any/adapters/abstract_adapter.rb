# frozen_string_literal: true

module ActiveAny
  class AbstractAdapter < Adapter
    %i[base_hander regexp_handler range_handler array_handler].each do |method|
      define_method method do |_record, _key, value|
        raise NotImplementedError.new, "#{self.class.name} can not handle for #{value.class}"
      end
    end

    def query(_where_clause, _limit_value = nil, _group_values = [], _order_values = [])
      raise NotImplementedError.new, "#{self.class.name} can not handle for #{value.class}"
    end

    def limit_handler(_records, _limit_value)
      raise NotImplementedError.new, "#{self.class.name} can not handle for limit"
    end

    def group_handler(_records, _group_values)
      raise NotImplementedError.new, "#{self.class.name} can not handle for group"
    end

    def order_handler(_records, _order_values)
      raise NotImplementedError.new, "#{self.class.name} can not handle for order"
    end
  end
end
