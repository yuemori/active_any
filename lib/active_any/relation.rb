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

    def records
      load
      @records
    end

    def to_a
      records.dup
    end

    def load
      load_records unless loaded
      self
    end

    private

    def load_records
      @records = @klass.load
      @loaded = true
    end
  end
end
