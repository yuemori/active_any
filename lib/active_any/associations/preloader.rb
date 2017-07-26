# frozen_string_literal: true

require 'active_any/associations/preloader/association'
require 'active_any/associations/preloader/singular_association'
require 'active_any/associations/preloader/has_many'
require 'active_any/associations/preloader/has_one'
require 'active_any/associations/preloader/belongs_to'

module ActiveAny
  module Associations
    class Preloader
      NULL_RELATION = Struct.new(:values, :where_clause, :joins_values).new({}, Relation::WhereClause.empty, [])

      def preload(records, associations, scope = NULL_RELATION)
        records       = Array.wrap(records).compact.uniq
        associations  = Array.wrap(associations)

        if records.empty?
          []
        else
          associations.flat_map do |association|
            preloaders_on association, records, scope
          end
        end
      end

      private

      def preloaders_on(association, records, scope)
        case association
        when Symbol
          preloaders_for_one(association, records, scope)
        when String
          preloaders_for_one(association.to_sym, records, scope)
        else
          raise ArgumentError, "#{association.inspect} was not recognized for preload"
        end
      end

      def preloaders_for_one(association, records, scope)
        grouped_records(association, records).flat_map do |reflection, klasses|
          klasses.map do |rhs_klass, rs|
            loader = preloader_for(reflection, rs, rhs_klass).new(rhs_klass, rs, reflection, scope)
            loader.run self
            loader
          end
        end
      end

      def grouped_records(association, records)
        h = {}
        records.each do |record|
          next unless record
          assoc = record.association(association)
          klasses = h[assoc.reflection] ||= {}
          (klasses[assoc.klass] ||= []) << record
        end
        h
      end

      class AlreadyLoaded
        attr_reader :owners, :reflection

        def initialize(_klass, owners, reflection, _preload_scope)
          @owners = owners
          @reflection = reflection
        end

        def run(preloader); end

        def preloaded_records
          owners.flat_map { |owner| owner.association(reflection.name).target }
        end
      end

      class NullPreloader
        def self.new(_klass, _owners, _reflection, _preload_scope)
          self
        end

        def self.run(_preloader); end

        def self.preloaded_records
          []
        end

        def self.owners
          []
        end
      end

      def preloader_for(reflection, owners, rhs_klass)
        return NullPreloader unless rhs_klass

        if owners.first.association(reflection.name).loaded?
          return AlreadyLoaded
        end
        reflection.check_preloadable!

        case reflection.macro
        when :has_many
          # reflection.options[:through] ? HasManyThrough : HasMany
          HasMany
        when :has_one
          # reflection.options[:through] ? HasOneThrough : HasOne
          HasOne
        when :belongs_to
          BelongsTo
        end
      end
    end
  end
end
