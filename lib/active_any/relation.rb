# frozen_string_literal: true

require 'active_any/relation/merger'
require 'active_any/relation/where_clause'
require 'active_any/relation/order_clause'

module ActiveAny
  class Relation # rubocop:disable Metrics/ClassLength
    attr_reader :loaded, :klass

    delegate :each, to: :records

    include Enumerable

    class ImmutableRelation < StandardError; end

    MULTI_VALUE_METHODS  = %i[group includes join].freeze
    SINGLE_VALUE_METHODS = %i[limit].freeze
    CLAUSE_METHODS = %i[where order].freeze
    VALUE_METHODS = (MULTI_VALUE_METHODS + SINGLE_VALUE_METHODS + CLAUSE_METHODS).freeze

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

    def self.create(klass, *args)
      new(klass, *args)
    end

    def initialize(klass)
      @klass = klass
      @records = []
      @loaded = false
      @values = {}
    end

    def get_value(name)
      @values[name] || default_value_for(name)
    end

    def set_value(name, value)
      assert_mutability!
      @values[name] = value
    end

    def to_a
      records.dup
    end

    def limit(value)
      spawn.limit!(value)
    end

    def where(condition)
      spawn.where!(condition)
    end

    def find_by(condition)
      where(condition).take
    end

    def take(limit = nil)
      limit ? find_take_with_limit(limit) : find_take
    end

    def first(limit = nil)
      if loaded
        limit ? records.first(limit) : records.first
      else
        limit ? spawn.records.first(limit) : spawn.records.first
      end
    end

    def last(limit = nil)
      return find_last(limit) if loaded? || limit_value

      result = limit(limit)
      result.order!(klass.primary_key) if order_clause.empty? && klass.primary_key
      result = result.reverse_order!
      limit ? result.reverse : result.first
    end

    def reverse_order
      spawn.reverse_order!
    end

    def reverse_order!
      self.order_clause = order_clause.reverse!
      self
    end

    def find_last(limit)
      limit ? records.last(limit) : records.last
    end

    def group(*args)
      spawn.group!(*args)
    end

    def order(*args)
      spawn.order!(*args)
    end

    def merge(other)
      if other.is_a?(Array)
        records & other
      elsif other
        spawn.merge!(other)
      else
        raise ArgumentError, "invalid argument: #{other.inspect}."
      end
    end

    def merge!(other) # :nodoc:
      if other.is_a?(Hash)
        Relation::HashMerger.new(self, other).merge
      elsif other.is_a?(Relation)
        Relation::Merger.new(self, other).merge
      elsif other.respond_to?(:to_proc)
        instance_exec(&other)
      else
        raise ArgumentError, "#{other.inspect} is not an ActiveRecord::Relation"
      end
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

    def records
      load
      @records
    end

    def initialize_copy(*)
      @values = @values.dup
      reset
      super
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

    def values
      @values.dup
    end

    def reset
      @loaded = nil
      @records = [].freeze
      self
    end

    def loaded?
      @loaded
    end

    def load
      exec_query unless loaded
      self
    end

    private

    def spawn
      clone
    end

    def find_take_with_limit(limit)
      if loaded
        records.take(limit)
      else
        limit(limit).to_a
      end
    end

    def find_take
      if loaded
        records.first
      else
        limit(1).records.first
      end
    end

    def clauses
      {
        where_clause: where_clause,
        limit_value: limit_value,
        group_values: group_values,
        order_clause: order_clause
      }
    end

    def exec_query
      ActiveSupport::Notifications.instrument('exec_query.active_any', clauses: clauses, class_name: klass.name) do
        @records = klass.find_by_query(clauses)
        preload_records(@records)
        @loaded = true
      end
    end

    def eager_loading?
      false
    end

    def preload_records(records)
      # TODO: implement preload
      # preload = preload_values
      preload = []
      preload += includes_values unless eager_loading?
      preloader = nil
      preload.each do |associations|
        preloader ||= build_preloader
        preloader.preload records, associations
      end
    end

    def build_preloader
      ActiveAny::Associations::Preloader.new
    end

    def assert_mutability!
      raise ImmutableRelation if @loaded
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
  end
end
