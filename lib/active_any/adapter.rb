# frozen_string_literal: true

module ActiveAny
  class Adapter
    def initialize(klass)
      @klass = klass
    end

    def query(_where_clause, _limit_value)
      raise NotImplementedError
    end
  end
end
