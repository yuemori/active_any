# frozen_string_literal: true

module ActiveAny
  module Associations
    class Preloader
      class BelongsTo < Association
        def preload(preloader)
          associated_records_by_owner(preloader).each do |owner, associated_records|
            record = associated_records.first

            association = owner.association(reflection.name)
            association.target = record
          end
        end

        def association_key_name
          reflection.options[:primary_key] || klass && klass.primary_key
        end

        def owner_key_name
          reflection.foreign_key
        end
      end
    end
  end
end
