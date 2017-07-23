# frozen_string_literal: true

module ActiveAny
  module Core
    extend ActiveSupport::Concern

    included do
      class_attribute :abstract_class, instance_writer: false
      class_attribute :primary_key, instance_writer: false
      self.abstract_class = true
      self.primary_key = nil
    end

    class_methods do
      delegate :take, :take!, :first, :last, to: :all
    end

    def initialize(data)
      init_internals
      assign_attributes(data)
    end

    private

    def init_internals; end
  end
end
