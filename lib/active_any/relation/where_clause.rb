# frozen_string_literal: true

module ActiveAny
  class Relation
    class WhereClause
      class Condition
        attr_reader :key, :value

        def initialize(key, value)
          @key = key
          @value = value

          register_handler(BasicObject, :base_handler)
          register_handler(Regexp, :regexp_handler)
          register_handler(Range, :range_handler)
          register_handler(Array, :array_handler)
        end

        def evaluate(adapter, record = nil)
          adapter.public_send(handle_for(value), record, key, value)
        end

        def to_h
          { key => value }
        end

        private

        def handle_for(value)
          handlers.select { |klass, _| value.is_a?(klass) }.last.last
        end

        def handlers
          @handlers ||= []
        end

        def register_handler(klass, method)
          handlers << [klass, method]
        end
      end

      attr_reader :conditions

      def initialize(hash = {}, conditions = nil)
        @conditions = conditions ? conditions : hash.map { |key, value| Condition.new(key, value) }
      end

      def self.empty
        new
      end

      def ==(other)
        other.conditions.sort_by(&:key) == conditions.sort_by(&:key)
      end

      def +(other)
        WhereClause.new({}, (conditions + other.conditions).flatten)
      end

      alias merge +

      def merge!(hash)
        hash.each do |key, value|
          conditions << Condition.new(key, value)
        end
      end

      include Enumerable

      def each(&block)
        conditions.each(&block)
      end
    end
  end
end
