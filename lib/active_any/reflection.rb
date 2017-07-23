# frozen_string_literal: true

require 'active_any/reflections/has_many_reflection'

module ActiveAny
  module Reflection
    extend ActiveSupport::Concern

    included do
      class_attribute :reflections, instance_writer: false
      self.reflections = {}
    end

    def self.create(macro, name, scope, options, klass)
      reflection_class =
        case macro
        when :has_many
          HasManyReflection
        else
          raise "Unsupported Macro: #{macro}"
        end

      reflection_class.new(name, scope, options, klass)
    end

    def self.add_reflection(klass, name, reflection)
      klass.reflections = klass.reflections.merge(name.to_s => reflection)
    end
  end
end
