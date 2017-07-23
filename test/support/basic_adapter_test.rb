# frozen_string_literal: true

module BasicAdapterTest
  def data
    test_class.data
  end

  def test_class
    raise NotImplementedError
  end

  def adapter_class
    raise NotImplementedError
  end

  def setup
    @adapter = adapter_class.new(test_class)
  end

  def where_clause
    ActiveAny::WhereClause
  end

  def test_respond_to_interfaces
    %i[query base_hander regexp_handler range_handler array_handler group_handler].each do |method|
      assert { @adapter.respond_to? method }
    end
  end

  def test_query_with_limit_value
    assert { @adapter.query(where_clause.new, 0) == [] }
    assert { @adapter.query(where_clause.new, 1) == data[0..0] }
    assert { @adapter.query(where_clause.new, 2) == data[0..1] }
    assert { @adapter.query(where_clause.new) == data }
  end

  def test_query_with_where_by_equal
    assert { @adapter.query(where_clause.new(id: 1)) == [data[0]] }
    assert { @adapter.query(where_clause.new(id: 3)) == [data[2]] }
    assert { @adapter.query(where_clause.new(name: 'foo')) == [data[0], data[3]] }
    assert { @adapter.query(where_clause.new(id: 1, name: 'foo')) == [data[0]] }
    assert { @adapter.query(where_clause.new(id: 1, name: 'bar')) == [] }
  end

  def test_query_with_where_by_array
    assert { @adapter.query(where_clause.new(id: [1, 2])) == data[0..1] }
    assert { @adapter.query(where_clause.new(id: [3, 4])) == data[2..3] }
  end

  def test_query_with_where_by_regexp
    assert { @adapter.query(where_clause.new(name: /^foo/)) == [data[0], data[3]] }
    assert { @adapter.query(where_clause.new(name: /^b/)) == data[1..2] }
  end

  def test_query_with_where_by_range
    assert { @adapter.query(where_clause.new(id: 1..4)) == data }
    assert { @adapter.query(where_clause.new(id: 1..2)) == data[0..1] }
  end

  def test_query_with_group
    assert { @adapter.query(where_clause.new, nil, []) == data }
    assert { @adapter.query(where_clause.new, nil, %i[name]) == [data[0], data[1], data[2]] }
  end

  def order_value
    Struct.new(:key, :sort_type)
  end

  def test_query_with_order
    assert { @adapter.query(where_clause.new, nil, [], []) == data }
    assert { @adapter.query(where_clause.new, nil, [], [order_value.new(:name, :asc)]) == [data[1], data[2], data[0], data[3]] }
    assert { @adapter.query(where_clause.new, nil, [], [order_value.new(:name, :desc)]) == [data[0], data[3], data[2], data[1]] }
    assert { @adapter.query(where_clause.new, nil, [], [order_value.new(:name, :desc), order_value.new(:id, :desc)]) == [data[3], data[0], data[2], data[1]] }
  end
end
