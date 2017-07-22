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

  def test_respond_to_interfaces
    %i[query base_hander regexp_handler range_handler array_handler].each do |method|
      assert { @adapter.respond_to? method }
    end
  end

  def test_query_with_limit_value
    assert { @adapter.query(ActiveAny::WhereClause.new, 0) == [] }
    assert { @adapter.query(ActiveAny::WhereClause.new, 1) == data[0..0] }
    assert { @adapter.query(ActiveAny::WhereClause.new, 2) == data[0..1] }
    assert { @adapter.query(ActiveAny::WhereClause.new) == data }
  end

  def test_where_with_equal_handler
    assert { @adapter.query(ActiveAny::WhereClause.new(id: 1)) == [data[0]] }
    assert { @adapter.query(ActiveAny::WhereClause.new(id: 3)) == [data[2]] }
    assert { @adapter.query(ActiveAny::WhereClause.new(name: 'foo')) == [data[0], data[3]] }
    assert { @adapter.query(ActiveAny::WhereClause.new(id: 1, name: 'foo')) == [data[0]] }
    assert { @adapter.query(ActiveAny::WhereClause.new(id: 1, name: 'bar')) == [] }
  end

  def test_where_with_array_handler
    assert { @adapter.query(ActiveAny::WhereClause.new(id: [1, 2])) == data[0..1] }
    assert { @adapter.query(ActiveAny::WhereClause.new(id: [3, 4])) == data[2..3] }
  end

  def test_where_with_regexp_handler
    assert { @adapter.query(ActiveAny::WhereClause.new(name: /^foo/)) == [data[0], data[3]] }
    assert { @adapter.query(ActiveAny::WhereClause.new(name: /^b/)) == data[1..2] }
  end

  def test_where_with_range_handler
    assert { @adapter.query(ActiveAny::WhereClause.new(id: 1..4)) == data }
    assert { @adapter.query(ActiveAny::WhereClause.new(id: 1..2)) == data[0..1] }
  end
end
