# frozen_string_literal: true

module ActiveAny
  module Associations
    module Builder
      class Association
        def self.build(klass, name, scope, options)
          reflection = create_reflection(klass, name, scope, options)
          define_accessors klass, reflection
          reflection
        end

        VALID_OPTIONS = %i[class_name foreign_key].freeze

        def self.valid_options(_options)
          VALID_OPTIONS
        end

        def self.validate_options(options)
          options.assert_valid_keys(valid_options(options))
        end

        def self.create_reflection(klass, name, scope, options)
          if scope.is_a?(::Hash)
            options = scope
            scope   = nil
          end

          validate_options(options)
          scope = build_scope scope

          ActiveAny::Reflection.create(macro, name, scope, options, klass)
        end

        def self.build_scope(scope)
          new_scope = scope

          new_scope = proc { instance_exec(&scope) } if scope && scope.arity.zero?

          new_scope
        end

        def self.define_accessors(klass, reflection)
          mixin = klass.generated_association_methods
          name = reflection.name
          define_readers(mixin, name)
          define_writers(mixin, name)
        end

        def self.define_readers(mixin, name)
          mixin.class_eval <<-CODE, __FILE__, __LINE__ + 1
            def #{name}(*args)
              association(:#{name}).reader(*args)
            end
          CODE
        end

        def self.define_writers(mixin, name)
          mixin.class_eval <<-CODE, __FILE__, __LINE__ + 1
            def #{name}=(value)
              association(:#{name}).writer(value)
            end
          CODE
        end
      end
    end
  end
end
