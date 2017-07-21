# frozen_string_literal: true

require 'test_helper'

class ActiveAnyTest < Minitest::Test
  class TestObject
    include ActiveAny::Object
  end

  def test_that_it_has_a_version_number
    refute_nil ::ActiveAny::VERSION
  end

  def test_all_returns_relation_object
    relation = TestObject.all

    assert { relation.is_a?(ActiveAny::Relation) }
  end
end
