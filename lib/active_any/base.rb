# frozen_string_literal: true

require 'csv'
require 'pathname'

module ActiveAny
  class Base
    extend Delegation::DelegateCache

    include Core
    include Attribute
    include Associations
    include AttributeAssignment
    include Finders
    include Reflection
  end

  class Object < Base
    self.abstract_class = true

    class << self
      attr_accessor :data

      def adapter
        @adapter ||= ObjectAdapter.new(self)
      end
    end
  end

  class Hash < Base
    self.abstract_class = true

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
    self.abstract_class = true

    class MissingFileError; end

    class << self
      attr_reader :file

      def file=(file)
        csv = ::CSV.new(file, headers: true)
        headers = csv.first
        headers.each { |header| attribute header }
      end

      def data
        @data ||= begin
          raise MissingFileError unless file

          table = ::CSV.table(file)
          table.map { |row| new(row.to_h) }
        end
      end

      def reload
        @data = nil
        data
      end

      def adapter
        @adapter ||= ObjectAdapter.new(self)
      end
    end
  end
end
