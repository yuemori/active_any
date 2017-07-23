# frozen_string_literal: true

require 'active_any/version'
require 'active_any/relation'
require 'active_any/adapter'
require 'active_any/adapters/abstract_adapter'
require 'active_any/adapters/object_adapter'
require 'active_any/where_clause'
require 'forwardable'

module ActiveAny
  class Abstract
    class << self
      extend Forwardable

      def_delegators :all, :find_by, :limit, :where, :take

      def all
        Relation.create(self)
      end

      def find_by_query(where_clause, limit_value, group_values, order_values)
        adapter.query(where_clause, limit_value, group_values, order_values)
      end

      def adapter
        raise NotImplementedError
      end
    end
  end

  class Object < Abstract
    class << self
      attr_accessor :data

      def adapter
        @adapter ||= ObjectAdapter.new(self)
      end
    end
  end

  class Hash < Abstract
    def initialize(data)
      data.each do |key, value|
        public_send("#{key}=", value)
      end
    end

    class << self
      attr_reader :data

      def data=(data)
        data.map(&:keys).flatten.each do |method|
          attr_accessor method
        end

        @data = data.map { |d| new(d) }
      end

      def adapter
        @adapter ||= ObjectAdapter.new(self)
      end
    end
  end
end
