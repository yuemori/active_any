# frozen_string_literal: true

module ActiveAny
  module Associations
    class Preloader
      class HasMany < Association
        def preload(preloader)
          associated_records_by_owner(preloader).each do |owner, records|
            association = owner.association(reflection.name)
            association.loaded!
            association.target.concat(records)
          end
        end

        def association_key_name
          reflection.foreign_key
        end

        def owner_key_name
          reflection.record_class_primary_key
        end
      end
    end
  end
end
