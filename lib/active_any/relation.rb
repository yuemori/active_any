# frozen_string_literal: true

module ActiveAny
  class Relation
    attr_reader :loaded

    def self.create(klass)
      new(klass)
    end

    def initialize(klass)
      @klass = klass
      @records = []
      @loaded = false
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

    protected

    def limit!(value)
      @limit_value = value
      self
    end

    def where!(condition)
      where_clause.merge!(condition)
      self
    end

    def records
      load
      @records
    end

    private

    def load
      load_records unless loaded
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

    def where_clause
      @where_clause ||= {}
    end

    def load_records
      records = exec_query
      records = records.take(@limit_value) if @limit_value
      @records = records
      @loaded = true
    end

    def exec_query
      records = @klass.load
      return records if where_clause.empty?

      records.select do |r|
        where_clause.all? do |key, value|
          r.send(key) == value
        end
      end
    end
  end
end
