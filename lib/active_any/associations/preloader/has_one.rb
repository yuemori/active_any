# frozen_string_literal: true

module ActiveAny
  module Associations
    class Preloader
      class HasOne < SingularAssociation
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
