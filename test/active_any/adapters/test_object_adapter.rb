# frozen_string_literal: true

require 'test_helper'

class ObjectAdapterTest < Minitest::Test
  include BasicAdapterTest

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

  def test_class
    TestObject
  end

  def adapter_class
    ActiveAny::ObjectAdapter
  end
end
