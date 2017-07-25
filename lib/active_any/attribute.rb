# frozen_string_literal: true

module ActiveAny
  module Attribute
    extend ActiveSupport::Concern

    def attributes
      @attributes ||= {}
    end

    def has_attribute?(attribute)
      attributes.key?(attribute)
    end

    def read_attribute(name)
      attributes.fetch(name)
    end

    def attribute_for_inspect(attr_name)
      value = read_attribute(attr_name)

      if value.is_a?(String) && value.length > 50
        "#{value[0, 50]}...".inspect
      elsif value.is_a?(Date) || value.is_a?(Time)
        %("#{value.to_s(:db)}")
      else
        value.inspect
      end
    end

    def inspect
      inspection = self.class.attribute_names.collect do |name|
        "#{name}: #{attribute_for_inspect(name)}" if has_attribute?(name)
      end.compact.join(', ')

      "#<#{self.class} #{inspection}>"
    end

    module ClassMethods
      def attributes(*names)
        names.each { |name| attribute name }
      end

      def attribute(name)
        attribute_names << name.to_sym
        define_writer_method name
        define_reader_method name
      end

      def attribute_names
        @attribute_names ||= []
      end

      def define_writer_method(name)
        define_method "#{name}=" do |value|
          attributes[name] = value
        end
      end

      def define_reader_method(name)
        define_method name do
          attributes.fetch(name, nil)
        end
      end

      def has_attribute?(attribute)
        attribute_names.key?(attribute)
      end
    end
  end
end
