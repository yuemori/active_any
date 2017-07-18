# frozen_string_literal: true

require 'test_helper'

class RelationTest < Minitest::Test
  class EmptyObject
    def self.load
      []
    end

    attr_reader :id, :name

    def initialize(id:, name:)
      @id = id
      @name = name
    end

    def ==(other)
      other.id == id
    end
  end

  class TestObject < EmptyObject
    def self.load
      [
        new(id: 1, name: :foo),
        new(id: 2, name: :bar),
        new(id: 3, name: :baz)
      ]
    end
  end

  def setup
    @relation = ActiveAny::Relation.new(TestObject)
    @empty_relation = ActiveAny::Relation.new(EmptyObject)
  end

  def test_should_equal_loader_methods_and_load
    assert { @relation.to_a == TestObject.load }
    assert { @empty_relation.to_a == [] }
  end

  def test_should_load_object_be_cached
    count = 0
    TestObject.stub :load, -> { count += 1 } do
      2.times { @relation.to_a }
    end

    assert { count == 1 }
  end

  def test_take_with_limit
    assert { @relation.take == TestObject.load.first }
    assert { @relation.take(2) == TestObject.load.take(2) }
    assert { @empty_relation.take.nil? }
    assert { @empty_relation.take(3) == [] }
  end

  def test_limit_value_be_affection_to_result
    assert { @relation.limit(1).is_a? ActiveAny::Relation }
    assert { @relation.limit(1).to_a == TestObject.load.take(1) }
    assert { @relation.limit(3).to_a == TestObject.load.take(3) }
    assert { @empty_relation.limit(1).to_a == [] }
    assert { @empty_relation.limit(3).to_a == [] }
  end

  def test_where_with_condition
    assert { @relation.where(id: 1).is_a? ActiveAny::Relation }
    assert { @relation.where(id: 1).to_a == [TestObject.load.first] }
    assert { @relation.where(id: 3).to_a == [TestObject.load.last] }
    assert { @relation.where(id: 1).where(id: 3).to_a == [] }
    assert { @relation.where(id: 1).where(name: :foo).to_a == [TestObject.load.first] }
    # TODO: enable chain clause
    # assert { @relation.where.not(id: 1).to_a == TestObject.load[1..2] }
    # assert { @relation.where(id: 1).or(@relation.where(id: 2)).to_a == TestObject.load[0..1] }
  end

  def test_find_by_with_condition
    assert { @relation.find_by(id: 1).is_a? TestObject }
    assert { @relation.find_by(id: 1) == TestObject.load.first }
    assert { @relation.find_by(id: 3) == TestObject.load.last }
    assert { @empty_relation.find_by(id: 1).nil? }
  end
end
