# frozen_string_literal: true

module ActiveAny
  module Associations
    class Preloader
      class SingularAssociation < Association
        def preload(preloader)
          associated_records_by_owner(preloader).each do |owner, associated_records|
            record = associated_records.first

            association = owner.association(reflection.name)
            association.target = record
          end
        end
      end
    end
  end
end
