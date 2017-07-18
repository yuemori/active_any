# frozen_string_literal: true

require 'active_any/version'
require 'active_any/relation'
require 'active_any/adapter'
require 'active_any/where_clause'

module ActiveAny
  def self.included(klass)
    klass.extend ClassMethods
  end

  module ClassMethods
    def all
      Relation.create(self)
    end
  end
end
