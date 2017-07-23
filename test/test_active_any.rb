# frozen_string_literal: true

require 'test_helper'
require 'data'

class ActiveAnyTest < Minitest::Test
  include TestData

  def test_that_it_has_a_version_number
    assert { !::ActiveAny::VERSION.nil? }
  end

  def test_all_returns_relation_object
    assert { UserObject.all.is_a?(ActiveAny::Relation) }
    assert { UserHash.all.is_a?(ActiveAny::Relation) }
    assert { UserObject.all.to_a.is_a?(Array) }
    assert { UserHash.all.to_a.is_a?(Array) }
  end
end
