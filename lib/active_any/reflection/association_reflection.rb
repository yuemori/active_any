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

      def scope_for(klass)
        scope ? klass.unscoped.instance_exec(nil, &scope) : klass.unscoped
      end

      def check_preloadable!
        return unless scope

        if scope.arity.positive?
          raise ArgumentError, <<-MSG.squish
            The association scope '#{name}' is instance dependent (the scope
            block takes an argument). Preloading instance dependent scopes is
            not supported.
          MSG
        end
      end
      alias check_eager_loadable! check_preloadable!

      def inverse_of
        return unless inverse_name

        @inverse_of ||= klass._reflect_on_association inverse_name
      end

      def record_class_primary_key
        @primary_key ||= options[:primary_key] || primary_key(record_class)
      end

      private

      def primary_key(record_class)
        record_class.primary_key || (raise UnknownPrimaryKey.new, klass)
      end

      def inverse_name
        options.fetch(:inverse_of) do
          @automatic_inverse_of ||= automatic_inverse_of
        end
      end

      def automatic_inverse_of
        if can_find_inverse_of_automatically?(self)
          inverse_name = ActiveSupport::Inflector.underscore(options[:as] || record_class.name.demodulize).to_sym

          begin
            reflection = klass._reflect_on_association(inverse_name)
          rescue NameError
            # Give up: we couldn't compute the klass type so we won't be able
            # to find any associations either.
            reflection = false
          end

          return inverse_name if valid_inverse_reflection?(reflection)
        end

        false
      end

      VALID_AUTOMATIC_INVERSE_MACROS = %i[has_many has_one belongs_to].freeze
      INVALID_AUTOMATIC_INVERSE_OPTIONS = %i[foreign_key].freeze

      def can_find_inverse_of_automatically?(reflection)
        reflection.options[:inverse_of] != false &&
          VALID_AUTOMATIC_INVERSE_MACROS.include?(reflection.macro) &&
          INVALID_AUTOMATIC_INVERSE_OPTIONS.none? { |opt| reflection.options[opt] } &&
          !reflection.scope
      end

      def valid_inverse_reflection?(reflection)
        reflection &&
          klass.name == reflection.record_class.name &&
          can_find_inverse_of_automatically?(reflection)
      end

      def join_pk
        raise NotImplementedError
      end

      def join_fk
        raise NotImplementedError
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
