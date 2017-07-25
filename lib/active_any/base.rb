# frozen_string_literal: true

require 'csv'
require 'pathname'

module ActiveAny
  class Base
    include Core
    include Attribute
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
        data.map(&:keys).flatten.uniq.each do |method|
          attribute method
        end

        @data = data.map { |d| new(d) }
      end

      def adapter
        @adapter ||= ObjectAdapter.new(self)
      end
    end
  end

  class CSV < Base
    def self.inherited(child)
      child.abstract_class = false
    end

    class MissingFileError; end

    class << self
      attr_accessor :file

      def data
        @data ||= begin
          raise MissingFileError unless file

          table = ::CSV.table(file)
          table.headers.each do |header|
            attribute header
          end

          table.map { |row| new(row.to_h) }
        end
      end

      def adapter
        @adapter ||= ObjectAdapter.new(self)
      end
    end
  end
end
