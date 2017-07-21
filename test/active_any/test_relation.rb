# frozen_string_literal: true

require 'test_helper'

class RelationTest < Minitest::Test
  Result = Struct.new(:where_clause, :limit_value)

  class TestObject
    class << self
      attr_accessor :call_count

      def find_by_query(where_clause, limit_value)
        @call_count += 1
        [Result.new(where_clause.conditions.map(&:to_h), limit_value)]
      end
    end

    self.call_count = 0
  end

  def setup
    @relation = ActiveAny::Relation.new(TestObject)
  end

  def teardown
    TestObject.call_count = 0
  end

  def test_should_equal_loader_methods_and_load
    assert { @relation.to_a == [Result.new([], nil)] }
  end

  def test_should_load_object_be_cached
    2.times { @relation.to_a }

    assert { TestObject.call_count == 1 }
  end

  def test_take_with_limit
    assert { @relation.take == Result.new([], 1) }
    assert { @relation.take(2) == [Result.new([], 2)] }
  end

  def test_limit_value_be_affection_to_result
    assert { @relation.limit(1).is_a? ActiveAny::Relation }
    assert { @relation.limit(1).to_a == [Result.new([], 1)] }
    assert { @relation.limit(3).to_a == [Result.new([], 3)] }
  end

  def test_where_with_condition
    assert { @relation.where(id: 1).is_a? ActiveAny::Relation }
    assert { @relation.where(id: 1).to_a == [Result.new([{ id: 1 }], nil)] }
    assert { @relation.where(id: 3).to_a == [Result.new([{ id: 3 }], nil)] }
    assert { @relation.where(id: 1).where(id: 3).to_a == [Result.new([{ id: 1 }, { id: 3 }], nil)] }
    assert { @relation.where(id: 1).where(name: :foo).to_a == [Result.new([{ id: 1 }, { name: :foo }], nil)] }
    assert { @relation.where(id: 1, name: :foo).to_a == [Result.new([{ id: 1 }, { name: :foo }], nil)] }
  end

  def test_find_by_with_condition
    assert { @relation.find_by(id: 1) == Result.new([{ id: 1 }], 1) }
    assert { @relation.find_by(id: 3) == Result.new([{ id: 3 }], 1) }
    assert { @relation.find_by(id: 3, name: :foo) == Result.new([{ id: 3 }, { name: :foo }], 1) }
  end
end
