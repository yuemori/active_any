# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext'

require 'active_any/version'
require 'active_any/attribute'
require 'active_any/configuration'
require 'active_any/relation'
require 'active_any/reflection'
require 'active_any/associations'
require 'active_any/association_relation'
require 'active_any/attribute_assignment'
require 'active_any/finders'
require 'active_any/core'
require 'active_any/base'
require 'active_any/subscriber'
require 'active_any/adapters/abstract_adapter'
require 'active_any/adapters/object_adapter'

module ActiveAny
  def self.configure
    yield config
  end

  def self.config
    @config ||= Configuration.new
  end
end
