# frozen_string_literal: true

module ActiveAny
  class AssociationRelation < Relation
    def initialize(klass, association)
      super(klass)
      @association = association
    end

    def proxy_association
      @association
    end

    def ==(other)
      other == records
    end

    private

    def exec_queries
      super do |r|
        @association.set_inverse_instance r
        yield r if block_given?
      end
    end
  end
end
