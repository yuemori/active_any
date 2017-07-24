# frozen_string_literal: true

module ActiveAny
  module Associations
    module Builder
      class HasMany < Association
        def self.macro
          :has_many
        end

        def self.valid_options
          super + %i[primary_key]
        end
      end
    end
  end
end
