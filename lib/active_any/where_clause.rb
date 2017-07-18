# frozen_string_literal: true

module ActiveAny
  class WhereClause
    class Condition
      def initialize(key, value)
        @key = key
        @value = value
      end

      def match?(record)
        record.send(@key) == @value
      end
    end

    attr_reader :conditions

    def initialize
      @conditions = []
    end

    def merge!(hash)
      hash.each do |key, value|
        @conditions << Condition.new(key, value)
      end
    end

    def all?(&block)
      @conditions.all?(&block)
    end
  end
end
