# frozen_string_literal: true

module ActiveAny
  module Reflection
    class AssociationReflection
      attr_reader :name, :scope, :options, :record_class

      def initialize(name, scope, options, record_class)
        @name = name
        @record_class = record_class
        @options = options
        @scope = scope
      end

      def association_class
        raise NotImplementedError
      end

      def marco
        raise NotImplementedError
      end

      def class_name
        @class_name ||= (options[:class_name] || derive_class_name).to_s
      end

      def klass
        @klass ||= compute_class(class_name)
      end

      def compute_class(name)
        name.constantize
      end

      def collection?
        false
      end

      def belongs_to?
        false
      end

      JoinKeys = Struct.new(:key, :foreign_key)

      def join_keys
        JoinKeys.new(join_pk, join_fk)
      end

      def foreign_key
        @foreign_key ||= options[:foreign_key] || derive_foreign_key.freeze
      end

      def primary_key
        @primary_key ||= options[:primary_key] || primary_key_for_record_class
      end

      private

      def join_pk
        raise NotImplementedError
      end

      def join_fk
        raise NotImplementedError
      end

      def primary_key_for_record_class
        klass.primary_key || (raise UnknownPrimaryKey.new, klass)
      end

      def derive_class_name
        class_name = name.to_s
        class_name = class_name.singularize if collection?
        class_name.camelize
      end

      def derive_foreign_key
        if belongs_to?
          "#{name}_id"
        elsif options[:as]
          "#{options[:as]}_id"
        else
          record_class.name.foreign_key
        end
      end
    end
  end
end
