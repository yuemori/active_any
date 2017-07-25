# frozen_string_literal: true

module ActiveAny
  class Relation
    MULTI_VALUE_METHODS  = %i[group includes join].freeze
    SINGLE_VALUE_METHODS = %i[limit].freeze
    CLAUSE_METHODS = %i[where order].freeze
    VALUE_METHODS = (MULTI_VALUE_METHODS + SINGLE_VALUE_METHODS + CLAUSE_METHODS).freeze

    module QueryMethods # rubocop:disable Metrics/ModuleLength
      extend ActiveSupport::Concern

      Relation::VALUE_METHODS.each do |name|
        method_name = \
          case name
          when *Relation::MULTI_VALUE_METHODS then "#{name}_values"
          when *Relation::SINGLE_VALUE_METHODS then "#{name}_value"
          when *Relation::CLAUSE_METHODS then "#{name}_clause"
          end
        class_eval <<-CODE, __FILE__, __LINE__ + 1
          def #{method_name}                   # def includes_values
            get_value(#{name.inspect})         #   get_value(:includes)
          end                                  # end

          def #{method_name}=(value)           # def includes_values=(value)
            set_value(#{name.inspect}, value)  #   set_value(:includes, value)
          end                                  # end
        CODE
      end

      def get_value(name)
        @values[name] || default_value_for(name)
      end

      def set_value(name, value)
        assert_mutability!
        @values[name] = value
      end

      def values
        @values.dup
      end

      def limit(value)
        spawn.limit!(value)
      end

      def where(condition)
        spawn.where!(condition)
      end

      def take(limit = nil)
        limit ? find_take_with_limit(limit) : find_take
      end

      def reverse_order
        spawn.reverse_order!
      end

      def reverse_order!
        self.order_clause = order_clause.reverse!
        self
      end

      def group(*args)
        spawn.group!(*args)
      end

      def order(*args)
        spawn.order!(*args)
      end

      def limit!(value)
        self.limit_value = value
        self
      end

      def where!(condition)
        self.where_clause += WhereClause.new(condition)
        self
      end

      def group!(*args)
        args.flatten!

        self.group_values += args
        self
      end

      def order!(*args)
        args.flatten!

        self.order_clause += OrderClause.new(args)
        self
      end

      def includes(*args)
        spawn.includes!(*args)
      end

      def includes!(*args)
        args.reject!(&:blank?)
        args.flatten!

        self.includes_values |= args
        self
      end

      private

      def find_take
        if loaded
          records.first
        else
          limit(1).records.first
        end
      end

      def find_take_with_limit(limit)
        if loaded
          records.take(limit)
        else
          limit(limit).to_a
        end
      end

      FROZEN_EMPTY_ARRAY = [].freeze

      def default_value_for(name)
        case name
        when :where then WhereClause.empty
        when :order then OrderClause.empty
        when *Relation::MULTI_VALUE_METHODS then FROZEN_EMPTY_ARRAY
        when *Relation::SINGLE_VALUE_METHODS then nil
        else
          raise ArgumentError, "unknown relation value #{name.inspect}"
        end
      end

      def assert_mutability!
        raise ImmutableRelation if @loaded
      end
    end
  end
end
