# frozen_string_literal: true

require 'active_any/associations/preloader/association'

module ActiveAny
  module Associations
    class Preloader
      class Association
        attr_reader :reflection, :preload_scope, :owners, :klass, :preloaded_records

        def initialize(klass, owner_records, reflection, preload_scope)
          @klass = klass
          @owners = owner_records
          @reflection = reflection
          @preload_scope = preload_scope
          @preloaded_records = []
        end

        def run(preloader)
          preload(preloader)
        end

        def preload(_preloader)
          raise NotImplementedError
        end

        def scope
          @scope ||= build_scope
        end

        def records_for(ids)
          scope.where(association_key_name => ids)
        end

        # The name of the key on the associated records
        def association_key_name
          raise NotImplementedError
        end

        def owner_key_name
          raise NotImplementedError
        end

        def options
          reflection.options
        end

        private

        def associated_records_by_owner(_preloader)
          records = load_records do |record|
            owner = owners_by_key[record[association_key_name]]
            association = owner.association(reflection.name)
            association.set_inverse_instance(record)
          end

          owners.each_with_object({}) do |owner, result|
            result[owner] = records[owner[owner_key_name]] || []
          end
        end

        def owners_by_key
          @owners_by_key ||= owners.each_with_object({}) do |owner, h|
            h[owner[owner_key_name]] = owner
          end
        end

        def owner_keys
          @owner_keys ||= owners.map do |owner|
            owner[owner_key_name]
          end.uniq.compact
        end

        def load_records
          return {} if owner_keys.empty?
          @preloaded_records = records_for(owner_keys).load
          @preloaded_records.each do |record|
            yield record if block_given?
          end
          @preloaded_records.group_by do |record|
            record[association_key_name]
          end
        end

        def reflection_scope
          @reflection_scope ||= reflection.scope_for(klass)
        end

        def build_scope # rubocop:disable all
          scope = klass.unscoped

          values = reflection_scope.values
          preload_values = preload_scope.values

          scope.where_clause = reflection_scope.where_clause + preload_scope.where_clause
          # scope.references_values = Array(values[:references]) + Array(preload_values[:references])

          if preload_values[:select] || values[:select]
            scope._select!(preload_values[:select] || values[:select])
          end
          scope.includes! preload_values[:includes] || values[:includes]
          # if preload_scope.joins_values.any?
          #   scope.joins!(preload_scope.joins_values)
          # else
          #   scope.joins!(reflection_scope.joins_values)
          # end
          order_values = preload_values[:order] || values[:order]
          scope.order!(order_values) if order_values

          # if preload_values[:reordering] || values[:reordering]
          #   scope.reordering_value = true
          # end

          # if preload_values[:readonly] || values[:readonly]
          #   scope.readonly!
          # end

          # if options[:as]
          #   scope.where!(klass.table_name => { reflection.type => model.base_class.sti_name })
          # end

          # scope.unscope_values = Array(values[:unscope]) + Array(preload_values[:unscope])
          klass.default_scoped.merge(scope)
        end
      end
    end
  end
end
