# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'active_any'

require 'minitest/autorun'
require 'minitest-power_assert'
require 'pry-byebug'

Dir['test/support/**/*.rb'].each { |f| require File.expand_path(f) }
