# frozen_string_literal: true

require 'test_helper'

class HashAdapterTest < Minitest::Test
  include BasicAdapterTest

  def test_class
    Class.new do
      def self.data
        [
          { id: 1, name: 'foo' },
          { id: 2, name: 'bar' },
          { id: 3, name: 'baz' },
          { id: 4, name: 'foo' }
        ]
      end
    end
  end

  def adapter_class
    ActiveAny::HashAdapter
  end
end
