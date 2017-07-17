# frozen_string_literal: true

require 'test_helper'

class RelationTest < Minitest::Test
  class TestObject
    def self.load
      [
        new(id: 1),
        new(id: 2),
        new(id: 3)
      ]
    end

    attr_reader :id

    def initialize(id:)
      @id = id
    end

    def ==(other)
      other.id == id
    end
  end

  def setup
    @relation = ActiveAny::Relation.new(TestObject)
  end

  def test_should_equal_loader_methods_and_load
    assert { @relation.to_a == TestObject.load }
  end

  def test_should_load_object_be_cached
    count = 0
    TestObject.stub :load, -> { count += 1 } do
      2.times { @relation.to_a }
    end

    assert { count == 1 }
  end
end
