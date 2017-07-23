# frozen_string_literal: true

module TestData
  class PersonObject < ActiveAny::Object
    attr_reader :name, :age

    def initialize(name:, age:)
      @name = name
      @age = age
    end

    self.data = [
      new(name: 'alice',   age: 20),
      new(name: 'bob',     age: 20),
      new(name: 'charlie', age: 20),
      new(name: 'alice',   age: 30),
      new(name: 'bob',     age: 30),
      new(name: 'charlie', age: 30),
      new(name: 'alice',   age: 40),
      new(name: 'bob',     age: 40),
      new(name: 'charlie', age: 40),
      new(name: 'alice',   age: 50),
      new(name: 'bob',     age: 50),
      new(name: 'charlie', age: 50)
    ]
  end

  class PersonHash < ActiveAny::Hash
    self.data = [
      { name: 'alice',   age: 20 },
      { name: 'bob',     age: 20 },
      { name: 'charlie', age: 20 },
      { name: 'alice',   age: 30 },
      { name: 'bob',     age: 30 },
      { name: 'charlie', age: 30 },
      { name: 'alice',   age: 40 },
      { name: 'bob',     age: 40 },
      { name: 'charlie', age: 40 },
      { name: 'alice',   age: 50 },
      { name: 'bob',     age: 50 },
      { name: 'charlie', age: 50 }
    ]
  end
end
