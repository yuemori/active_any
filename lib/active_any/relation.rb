# frozen_string_literal: true

require 'active_any/relation/finder_methods'
require 'active_any/relation/query_methods'
require 'active_any/relation/delegation'
require 'active_any/relation/merger'
require 'active_any/relation/where_clause'
require 'active_any/relation/order_clause'

module ActiveAny
  class Relation
    attr_reader :loaded, :klass

    delegate :each, to: :records

    include Enumerable
    include FinderMethods
    include QueryMethods
    include Delegation

    class ImmutableRelation < StandardError; end

    def self.create(klass, *args)
      relation_class_for(klass).new(klass, *args)
    end

    def self.relation_class_for(klass)
      klass.relation_delegate_class(self)
    end

    def initialize(klass)
      @klass = klass
      @records = []
      @loaded = false
      @values = {}
    end

    def to_a
      records.dup
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
      if other.is_a?(::Hash)
        Relation::HashMerger.new(self, other).merge
      elsif other.is_a?(Relation)
        Relation::Merger.new(self, other).merge
      elsif other.respond_to?(:to_proc)
        instance_exec(&other)
      else
        raise ArgumentError, "#{other.inspect} is not an ActiveAny::Relation"
      end
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

    def eager_loading?
      false
    end

    def scoping
      # previous, klass.current_scope = klass.current_scope, self
      yield
      # ensure
      # klass.current_scope = previous
    end

    def inspect
      subject = loaded? ? records : self
      entries = subject.take([limit_value, 11].compact.min).map!(&:inspect)

      entries[10] = '...' if entries.size == 11

      "#<#{self.class.name} [#{entries.join(', ')}]>"
    end

    private

    def spawn
      clone
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
  end
end
