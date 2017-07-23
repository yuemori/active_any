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
  end
end
