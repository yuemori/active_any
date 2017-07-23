# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext'
require 'forwardable'

require 'active_any/version'
require 'active_any/relation'
require 'active_any/finders'
require 'active_any/adapter'
require 'active_any/adapters/abstract_adapter'
require 'active_any/adapters/object_adapter'
require 'active_any/where_clause'

module ActiveAny
  class Abstract
    include Finders
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
