# frozen_string_literal: true

module ActiveAny
  class WhereClause
    class Condition
      attr_reader :key, :value

      def initialize(key, value)
        @key = key
        @value = value
      end

      def match?(record)
        record.send(@key) == @value
      end

      def to_h
        { key => value }
      end
    end

    attr_reader :conditions

    def initialize(hash = {})
      @conditions = hash.map { |key, value| Condition.new(key, value) }
    end

    def ==(other)
      other.conditions.sort_by(&:key) == conditions.sort_by(&:key)
    end

    def merge!(hash)
      hash.each do |key, value|
        conditions << Condition.new(key, value)
      end
    end

    def all?(&block)
      conditions.all?(&block)
    end
  end
end
