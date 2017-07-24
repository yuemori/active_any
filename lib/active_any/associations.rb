# frozen_string_literal: true

require 'active_any/associations/collection_proxy'
require 'active_any/associations/association_scope'
require 'active_any/associations/builder/association'
require 'active_any/associations/builder/has_many'
require 'active_any/associations/builder/belongs_to'
require 'active_any/associations/association'
require 'active_any/associations/has_many_association'
require 'active_any/associations/belongs_to_association'

module ActiveAny
  module Associations
    extend ActiveSupport::Concern

    class AssociationNotFoundError < StandardError
      def initialize(record = nil, association_name = nil)
        if record && association_name
          super("Association named '#{association_name}' was not found on #{record.class.name}; perhaps you misspelled it?")
        else
          super('Association was not found.')
        end
      end
    end

    module ClassMethods
      def has_many(name, scope = nil, options = {})
        reflection = Builder::HasMany.build(self, name, scope, options)
        Reflection.add_reflection self, name, reflection
      end

      def belongs_to(name, scope = nil, options = {})
        reflection = Builder::BelongsTo.build(self, name, scope, options)
        Reflection.add_reflection self, name, reflection
      end
    end

    def initialize_dup(*)
      @association_cache = {}
      super
    end

    private

    def init_internals(*)
      @association_cache = {}
      super
    end

    def association(name)
      association = association_instance_get(name)

      if association.nil?
        reflection = self.class.reflections[name.to_s]
        raise AssociationNotFoundError.new(self, name) unless reflection

        association = reflection.association_class.new(self, reflection)
        association_instance_set(name, association)
      end

      association
    end

    def association_instance_get(name)
      @association_cache[name]
    end

    def association_instance_set(name, association)
      @association_cache[name] = association
    end
  end
end
