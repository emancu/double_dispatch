double_dispatch
========

[![Maintainability](https://api.codeclimate.com/v1/badges/23f111d2fc921ff531f6/maintainability)](https://codeclimate.com/github/emancu/double_dispatch/maintainability)

Call different functions depending on the runtime types of two objects.
Extremely simple to use and extend.

I personally use it to compensate the lack of _method overloading_ in Ruby and
separate concerns into smaller `modules`.

## Usage

1. Define a unique `dispatch_id` for each class using the `dispatch_as` method.

```ruby
class Dog
  include DoubleDispatch

  dispatch_as :dog

  def pet
    #...
  end
end

class Human
  include DoubleDispatch

  dispatch_as :human

  attr_accessor :name

  def initialize(name)
    @name = name
  end
end
```

2. Write concrete functions for each class you want handle

```ruby
module Salutations
  def salute_to_human(human)
    "Hi #{human.name}!"
  end

  def salute_to_dog(dog)
    dog.pet

    "Woof woof!"
  end
end
```

3. Call `double_dispatch` to handle different non-necessary-polymorphic objects.

```ruby
Dog.new.double_dispatch(:salute_to, Salutations)
# => "Woof woof!"

Human.new("Emiliano").double_dispatch(:salute_to, Salutations)
# => "Hi Emiliano!"
```

## Common patterns

### Create modules to encapsulate the logic

This is my favourite pattern.
Using the same example described above, we can create a better internal API if we
encapsulate all the salutation logic into a single `module`

```ruby
module Salutations
  def self.salute(somebody)
    somebody.double_dispatch(:salute_to, self)
  end

  def salute_to_human(human)
    "Hi #{human.name}!"
  end

  def salute_to_dog(dog)
    dog.pet

    "Woof woof!"
  end
end
```

And then, we use the module in a cleaner way:

```
Salutations.salute Dog.new
# => "Woof woof!"

Salutations.salute Human.new("Emiliano")
# => "Hi Emiliano!"
```

### Use `class.name` as `dispatch_id`

I frequently find myself using the same `dispatch_id` as the _class name_, so
I used to extend `DoubleDispatch` with the following snippet

```ruby
module DoubleDispatch
  module ByClassName
    module ClassMethods
      def dispatch_id
        @dispatch_id ||= self.name.split('::').last.downcase
      end
    end

    def self.included(base)
      base.include(::DoubleDispatch)
      base.extend(ClassMethods)
    end
  end
end
```


### Use _table's name_ as `dispatch_id`

Most of the time, we will use Active Record objects (or Sequel models, etc) in
our system and we want to identify these models by the table name.

Since this gem is flexible and easy to extend, I suggest to extend `DoubleDispatch`
with a specific module using the ORM-specific methods.

For example, an extension for `Sequel` models would be:

```ruby
module DoubleDispatch
  module ByTableName::Sequel
    module ClassMethods
      def dispatch_id
        @dispatch_id ||= self.table_name
      end
    end

    def self.included(base)
      base.include(::DoubleDispatch)
      base.extend(ClassMethods)
    end
  end
end
```

And use this logic in a single line:

```ruby
class User < Sequel::Model
  include DoubleDispatch::ByTableName::Sequel

  ...
end
```

As you can see, it won't **need** to call `dispatch_as` method, but you can always
call it and overwrite the `dispatch_id`. This is extremely useful when you define
more than a model over the same _table name_.
