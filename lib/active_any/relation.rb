# frozen_string_literal: true

module ActiveAny
  class Relation
    attr_reader :loaded

    extend Forwardable
    include Enumerable

    def_delegators :records, :each

    def self.create(klass)
      new(klass)
    end

    def initialize(klass)
      @klass = klass
      @records = []
      @loaded = false
      @group_values ||= []
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

    def group(*args)
      spawn.group!(*args)
    end

    protected

    attr_accessor :limit_value, :group_values

    def limit!(value)
      self.limit_value = value
      self
    end

    def where!(condition)
      where_clause.merge!(condition)
      self
    end

    def group!(*args)
      args.flatten!

      self.group_values += args
      self
    end

    def records
      load
      @records
    end

    private

    def where_clause
      @where_clause ||= WhereClause.new
    end

    def load
      exec_query unless loaded
      self
    end

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

    def exec_query
      @records = @klass.find_by_query(where_clause, limit_value, group_values)
      @loaded = true
    end
  end
end
