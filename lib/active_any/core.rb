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

      def new(*args, &block)
        if abstract_class? || self == Base
          raise NotImplementedError, "#{self} is an abstract class and cannot be instantiated."
        end

        super
      end

      def abstract_class?
        defined?(@abstract_class) && abstract_class == true
      end

      def generated_association_methods
        @generated_association_methods ||= begin
          mod = const_set(:GeneratedAssociationMethods, Module.new)
          private_constant :GeneratedAssociationMethods
          include mod

          mod
        end
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
