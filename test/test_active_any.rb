# frozen_string_literal: true

require 'test_helper'
require 'data'

class ActiveAnyTest < Minitest::Test
  include TestData

  def test_that_it_has_a_version_number
    assert { !::ActiveAny::VERSION.nil? }
  end

  def test_all_returns_relation_object
    assert { PersonObject.all.is_a?(ActiveAny::Relation) }
    assert { PersonHash.all.is_a?(ActiveAny::Relation) }
    assert { PersonObject.all.to_a.is_a?(Array) }
    assert { PersonHash.all.to_a.is_a?(Array) }
  end
end
