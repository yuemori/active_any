# frozen_string_literal: true

require 'test_helper'

class ObjectAdapterTest < Minitest::Test
  TestObject = Struct.new(:id, :name) do
    def self.data
      [
        TestObject.new(1, 'foo'),
        TestObject.new(2, 'bar'),
        TestObject.new(3, 'baz'),
        TestObject.new(4, 'foo')
      ]
    end
  end

  def data
    TestObject.data
  end

  def setup
    @adapter = ActiveAny::ObjectAdapter.new(TestObject)
  end

  def where_clause
    ActiveAny::Relation::WhereClause
  end

  def order_clause
    ActiveAny::Relation::OrderClause
  end

  def test_respond_to_interfaces
    %i[query base_hander regexp_handler range_handler array_handler group_handler].each do |method|
      assert { @adapter.respond_to? method }
    end
  end

  def test_query_with_limit_value
    assert { @adapter.query(limit_value: 0) == [] }
    assert { @adapter.query(limit_value: 1) == data[0..0] }
    assert { @adapter.query(limit_value: 2) == data[0..1] }
    assert { @adapter.query == data }
  end

  def test_query_with_where_by_equal
    assert { @adapter.query(where_clause: where_clause.new(id: 1)) == [data[0]] }
    assert { @adapter.query(where_clause: where_clause.new(id: 3)) == [data[2]] }
    assert { @adapter.query(where_clause: where_clause.new(name: 'foo')) == [data[0], data[3]] }
    assert { @adapter.query(where_clause: where_clause.new(id: 1, name: 'foo')) == [data[0]] }
    assert { @adapter.query(where_clause: where_clause.new(id: 1, name: 'bar')) == [] }
  end

  def test_query_with_where_by_array
    assert { @adapter.query(where_clause: where_clause.new(id: [1, 2])) == data[0..1] }
    assert { @adapter.query(where_clause: where_clause.new(id: [3, 4])) == data[2..3] }
  end

  def test_query_with_where_by_regexp
    assert { @adapter.query(where_clause: where_clause.new(name: /^foo/)) == [data[0], data[3]] }
    assert { @adapter.query(where_clause: where_clause.new(name: /^b/)) == data[1..2] }
  end

  def test_query_with_where_by_range
    assert { @adapter.query(where_clause: where_clause.new(id: 1..4)) == data }
    assert { @adapter.query(where_clause: where_clause.new(id: 1..2)) == data[0..1] }
  end

  def test_query_with_group
    assert { @adapter.query(group_values: []) == data }
    assert { @adapter.query(group_values: %i[name]) == [data[0], data[1], data[2]] }
  end

  def order_value
    Struct.new(:key, :sort_type)
  end

  def test_query_with_order
    assert { @adapter.query(order_clause: order_clause.new([{ name: :asc }])) == [data[1], data[2], data[0], data[3]] }
    assert { @adapter.query(order_clause: order_clause.new([{ name: :desc }])) == [data[0], data[3], data[2], data[1]] }
    assert { @adapter.query(order_clause: order_clause.new([{ name: :desc }, { id: :desc }])) == [data[3], data[0], data[2], data[1]] }
  end
end
