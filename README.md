# ActiveAny

[![Build Status](https://travis-ci.org/yuemori/active_any.svg?branch=master)](https://travis-ci.org/yuemori/active_any)

A utility for quering interface to any objects like ActiveRecord. This gem support for querying, association and relation.

**This gem is not stable version. Be careful.**

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'active_any'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install active_any

## Usage

### Getting Started

```ruby
class User < ActiveAny::Object
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
end

User.all                  #=> Relation
User.all.to_a             #=> Array of User
User.where(name: 'alice') #=> WHERE name = alice
User.where(name: /li/)    #=> WHERE name LIKE %li% (alice, charlie)
User.group(:name)         #=> GROUP BY name
User.order(:age)          #=> ORDER BY age
User.order(age: :desc)    #=> ORDER BY age DESC
User.limit(5)             #=> LIMIT 5

User.where(name: 'alice').group(:age).order(age: :desc).limit(1).first # Chain
```

Clone repository and run `bin/console`, if you want to try it!
(See [test/data.rb](test/data.rb) for defined data on console.)

## Features

- More powerful interface for select query
  - [ ] `joins`      (interface only)
  - [ ] `preload`    (interface only)
  - [ ] `eager_load` (interface only)
  - [ ] `includes`
  - [ ] `having`
  - [ ] `offset`
- Adapters
  - [ ] API
  - [ ] YAML
  - [ ] JSON
  - [ ] CSV
- ActiveRecord like interfaces
  - [ ] Interface for other than select query (create, destroy, update)
  - [ ] enum support
  - [ ] logging
  - [ ] scoping
- Integration
  - [ ] ActiveRecord
  - [ ] ActiveModelSerializers

## Testing

```sh
bin/setup
bundle exec rake test
bundle exec rubocop
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/yuemori/active_any. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ActiveAny project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/active_any/blob/master/CODE_OF_CONDUCT.md).
