# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext'

require 'active_any/version'
require 'active_any/relation'
require 'active_any/reflection'
require 'active_any/associations'
require 'active_any/association_relation'
require 'active_any/attribute_assignment'
require 'active_any/finders'
require 'active_any/core'
require 'active_any/subscriber'
require 'active_any/adapter'
require 'active_any/adapters/abstract_adapter'
require 'active_any/adapters/object_adapter'

module ActiveAny
  class Base
    include Core
    include Associations
    include AttributeAssignment
    include Finders
    include Reflection
  end

  class Object < Base
    def self.inherited(child)
      child.abstract_class = false
    end

    class << self
      attr_accessor :data

      def adapter
        @adapter ||= ObjectAdapter.new(self)
      end
    end
  end

  class Hash < Base
    def self.inherited(child)
      child.abstract_class = false
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
