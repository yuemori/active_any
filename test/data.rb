# frozen_string_literal: true

module TestData
  class UserObject < ActiveAny::Object
    attr_accessor :id, :name, :age

    self.data = [
      new(id: 1, name: 'alice',   age: 20),
      new(id: 2, name: 'bob',     age: 20),
      new(id: 3, name: 'charlie', age: 20),
      new(id: 4, name: 'alice',   age: 30),
      new(id: 5, name: 'bob',     age: 30),
      new(id: 6, name: 'charlie', age: 30),
      new(id: 7, name: 'alice',   age: 40),
      new(id: 8, name: 'bob',     age: 40),
      new(id: 9, name: 'charlie', age: 40),
      new(id: 10, name: 'alice',   age: 50),
      new(id: 11, name: 'bob',     age: 50),
      new(id: 12, name: 'charlie', age: 50)
    ]

    has_many :comments
  end

  class Comment < ActiveAny::Hash
    self.primary_key = :id

    self.data = [
      { id: 1, user_object_id: 1, message: 'hello 1' },
      { id: 2, user_object_id: 2, message: 'hello 2' },
      { id: 3, user_object_id: 3, message: 'hello 3' },
      { id: 4, user_object_id: 4, message: 'hello 4' },
      { id: 5, user_object_id: 5, message: 'hello 5' },
      { id: 6, user_object_id: 6, message: 'hello 6' },
      { id: 7, user_object_id: 7, message: 'hello 7' },
      { id: 8, user_object_id: 8, message: 'hello 8' },
      { id: 9, user_object_id: 9, message: 'hello 9' },
      { id: 11, user_object_id: 1, message: 'hello 11' },
      { id: 12, user_object_id: 1, message: 'hello 12' }
    ]
  end

  class UserHash < ActiveAny::Hash
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
