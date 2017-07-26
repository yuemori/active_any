# frozen_string_literal: true

module ActiveAny
  module Delegation
    extend ActiveSupport::Concern

    module DelegateCache
      def relation_delegate_class(klass)
        @relation_delegate_cache[klass]
      end

      def initialize_relation_delegate_cache
        @relation_delegate_cache = cache = {}
        [
          ActiveAny::Relation,
          ActiveAny::Associations::CollectionProxy,
          ActiveAny::AssociationRelation
        ].each do |klass|
          delegate = Class.new(klass) { include ClassSpecificRelation }
          mangled_name = klass.name.gsub('::', '_')
          const_set mangled_name, delegate
          private_constant mangled_name

          cache[klass] = delegate
        end
      end

      def inherited(child_class)
        child_class.initialize_relation_delegate_cache
        super
      end
    end

    module ClassSpecificRelation
      extend ActiveSupport::Concern

      included do
        @delegation_mutex = Mutex.new
      end

      module ClassMethods
        def name
          superclass.name
        end

        def delegate_to_scoped_klass(method)
          @delegation_mutex.synchronize do
            return if method_defined?(method)

            if /\A[a-zA-Z_]\w*[!?]?\z/.match?(method)
              module_eval <<-RUBY, __FILE__, __LINE__ + 1
                def #{method}(*args, &block)
                  scoping { @klass.#{method}(*args, &block) }
                end
              RUBY
            else
              define_method method do |*args, &block|
                scoping { @klass.public_send(method, *args, &block) }
              end
            end
          end
        end

        def delegate(method, opts = {})
          @delegation_mutex.synchronize do
            return if method_defined?(method)
            super
          end
        end
      end

      private

      def method_missing(method, *args, &block)
        if @klass.respond_to?(method)
          self.class.delegate_to_scoped_klass(method)
          scoping { @klass.public_send(method, *args, &block) }
        else
          super
        end
      end

      def respond_to_missing?(name, _)
        super || @klass.respond_to?(name)
      end
    end

    module ClassMethods
      def create(klass, *args)
        relation_class_for(klass).new(klass, *args)
      end

      def relation_class_for(klass)
        klass.relation_delegate_class(self)
      end
    end

    def respond_to_missing?(name, _)
      super || @klass.respond_to?(name)
    end
  end
end
