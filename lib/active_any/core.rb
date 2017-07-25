# frozen_string_literal: true

module ActiveAny
  module Core
    extend ActiveSupport::Concern

    included do
      class_attribute :primary_key, instance_writer: false
      self.primary_key = nil
    end

    class_methods do
      delegate :includes, :take, :take!, :first, :last, to: :all
    end

    module ClassMethods
      attr_accessor :abstract_class

      def unscoped
        # TODO: implement
        all
      end

      def default_scoped
        # TODO: implement
        all
      end
    end

    def initialize(*args)
      init_internals(*args)
    end

    def [](key)
      send(key)
    end

    private

    def init_internals(*); end
  end
end
