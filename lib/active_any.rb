# frozen_string_literal: true

require 'active_any/version'
require 'active_any/relation'
require 'active_any/adapter'
require 'active_any/adapters/abstract_adapter'
require 'active_any/adapters/basic_adapter'
require 'active_any/adapters/object_adapter'
require 'active_any/adapters/hash_adapter'
require 'active_any/where_clause'
require 'forwardable'

module ActiveAny
  module Object
    def self.included(klass)
      klass.extend ClassMethods
    end

    module ClassMethods
      extend Forwardable

      def_delegators :all, :find_by, :limit, :where, :take

      def all
        Relation.create(self)
      end

      def find_by_query(where_clause, limit_value)
        adapter.query(where_clause, limit_value)
      end

      private

      def adapter
        @adapter ||= ObjectAdapter.new(self)
      end
    end
  end

  module Hash
    def self.included(klass)
      klass.extend ClassMethods
    end

    module ClassMethods
      extend Forwardable

      def_delegators :all, :find_by, :limit, :where, :take

      def all
        Relation.create(self)
      end

      def find_by_query(where_clause, limit_value)
        adapter.query(where_clause, limit_value)
      end

      private

      def adapter
        @adapter ||= HashAdapter.new(self)
      end
    end
  end
end
