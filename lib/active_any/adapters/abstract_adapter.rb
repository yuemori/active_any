# frozen_string_literal: true

module ActiveAny
  class AbstractAdapter
    attr_reader :klass

    def initialize(klass)
      @klass = klass
    end

    %i[base_hander regexp_handler range_handler array_handler].each do |method|
      define_method method do |_record, _key, value|
        raise NotImplementedError.new, "#{self.class.name} can not handle for #{value.class}"
      end
    end

    def query(*)
      raise NotImplementedError.new, "#{self.class.name} can not handle for #{value.class}"
    end
  end
end
