# frozen_string_literal: true

require 'test_helper'

class ObjectAdapterTest < Minitest::Test
  TestObject = Struct.new(:id, :name) do
    def self.data
      [
        TestObject.new(1, :foo),
        TestObject.new(2, :bar),
        TestObject.new(3, :baz),
        TestObject.new(4, :foo)
      ]
    end
  end

  def data
    TestObject.data
  end

  def setup
    @adapter = ActiveAny::ObjectAdapter.new(TestObject)
  end

  def test_query_with_limit_value
    assert { @adapter.query(ActiveAny::WhereClause.new, 0) == [] }
    assert { @adapter.query(ActiveAny::WhereClause.new, 1) == data[0..0] }
    assert { @adapter.query(ActiveAny::WhereClause.new, 2) == data[0..1] }
    assert { @adapter.query(ActiveAny::WhereClause.new) == data }
  end

  def test_where_with_condition
    assert { @adapter.query(ActiveAny::WhereClause.new(id: 1)) == [data[0]] }
    assert { @adapter.query(ActiveAny::WhereClause.new(id: 3)) == [data[2]] }
    assert { @adapter.query(ActiveAny::WhereClause.new(name: :foo)) == [data[0], data[3]] }
    assert { @adapter.query(ActiveAny::WhereClause.new(id: 1, name: :foo)) == [data[0]] }
    assert { @adapter.query(ActiveAny::WhereClause.new(id: 1, name: :bar)) == [] }
  end
end
