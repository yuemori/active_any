# frozen_string_literal: true

module ActiveAny
  class Relation
    class HashMerger
      attr_reader :relation, :hash

      def initialize(relation, hash)
        hash.assert_valid_keys(*Relation::VALUE_METHODS)

        @relation = relation
        @hash     = hash
      end

      def merge
        Merger.new(relation, other).merge
      end

      def other
        other = Relation.create(relation.klass)
        hash.each { |k, v| other.public_send("#{k}!", v) }
        other
      end
    end

    class Merger
      attr_reader :relation, :values, :other

      def initialize(relation, other)
        @relation = relation
        @values   = other.values
        @other    = other
      end

      def normal_values
        Relation::VALUE_METHODS -
          Relation::CLAUSE_METHODS -
          %i[includes preload joins order reverse_order lock create_with reordering]
      end

      def merge
        normal_values.each do |name|
          value = values[name]
          relation.send("#{name}!", *value) unless value.nil? || (value.blank? && value != false)
        end

        merge_multi_values
        merge_single_values
        merge_clauses

        relation
      end

      private

      def merge_multi_values
        relation.order! other.order_clause unless other.order_clause.empty?
        relation.group! other.group_values if other.group_values
      end

      def merge_single_values; end

      def merge_clauses
        CLAUSE_METHODS.each do |method|
          clause = relation.get_value(method)
          other_clause = other.get_value(method)
          relation.set_value(method, clause.merge(other_clause))
        end
      end
    end
  end
end
