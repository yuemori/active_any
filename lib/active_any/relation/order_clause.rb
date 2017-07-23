# frozen_string_literal: true

module ActiveAny
  class Relation
    class OrderClause
      def self.empty
        new
      end

      OrderValue = Struct.new(:key, :sort_type)

      attr_reader :order_values

      def initialize(values = [], reverse = false)
        @reverse = reverse
        @order_values = convert_order_values(values)
      end

      def reverse?
        @reverse
      end

      def reverse!
        @reverse = true
        self
      end

      def +(other)
        OrderClause.new(
          order_values + other.order_values,
          reverse? || other.reverse?
        )
      end

      alias merge +

      def ==(other)
        reverse? == other.reverse? && order_values == other.order_values
      end

      def empty?
        order_values.empty?
      end

      private

      def convert_order_values(values)
        values.map do |arg|
          case arg
          when ::Hash then OrderValue.new(arg.keys.first, arg.values.first)
          when ::Symbol, ::String then OrderValue.new(arg, :asc)
          when OrderValue then arg
          else
            raise ArgumentError
          end
        end
      end
    end
  end
end
