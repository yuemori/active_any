# frozen_string_literal: true

module ActiveAny
  module Associations
    module Builder
      class BelongsTo < Association
        def self.macro
          :belongs_to
        end
      end
    end
  end
end
