# frozen_string_literal: true

require 'active_any/version'
require 'active_any/relation'
require 'active_any/adapter'
require 'active_any/where_clause'
require 'forwardable'

module ActiveAny
  def self.included(klass)
    klass.extend ClassMethods
  end

  module ClassMethods
    extend Forwardable

    def_delegators :all, :find_by, :limit, :where, :take

    def all
      Relation.create(self)
    end
  end
end
