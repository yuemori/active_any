# frozen_string_literal: true

require 'test_helper'

class HashAdapterTest < Minitest::Test
  TestObject = Class.new do
    def self.data
      [
        { id: 1, name: :foo },
        { id: 2, name: :bar },
        { id: 3, name: :baz },
        { id: 4, name: :foo }
      ]
    end
  end

  def data
    TestObject.data
  end

  def setup
    @adapter = ActiveAny::HashAdapter.new(TestObject)
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
