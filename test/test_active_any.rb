# frozen_string_literal: true

require 'test_helper'

class ActiveAnyTest < Minitest::Test
  class PersonObject
    include ActiveAny::Object

    attr_reader :name, :age

    def initialize(name:, age:)
      @name = name
      @age = age
    end

    def self.data
      [
        new(name: 'alice',   age: 20),
        new(name: 'bob',     age: 20),
        new(name: 'charlie', age: 20)
      ]
    end
  end

  class PersonHash
    include ActiveAny::Hash

    def self.data
      [
        { name: 'alice',   age: 20 },
        { name: 'bob',     age: 20 },
        { name: 'charlie', age: 20 }
      ]
    end
  end

  def test_that_it_has_a_version_number
    assert { !::ActiveAny::VERSION.nil? }
  end

  def test_all_returns_relation_object
    assert { PersonObject.all.is_a?(ActiveAny::Relation) }
    assert { PersonHash.all.is_a?(ActiveAny::Relation) }
    assert { PersonObject.all.to_a.is_a?(Array) }
    assert { PersonHash.all.to_a.is_a?(Array) }
  end
end
