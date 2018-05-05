require 'minitest/autorun'
require_relative '../lib/double_dispatch'

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

class TestDoubleDispatch < Minitest::Test
  class FailureTestingModel
    include DoubleDispatch
  end

  module Resolver
    module_function

    def perform_for_dog(dog, *args)
      [dog, args]
    end

    def perform_for_not_a_dog(dog, *args)
      'Not a dog'
    end

    def test_for_human(human)
      true
    end
  end

  class Dog
    include DoubleDispatch

    dispatch_as :dog
  end

  class Human
    include DoubleDispatch::ByClassName
  end

  def test_fails_when_dispatch_id_is_undefined
    assert_raises { FailureTestingModel.new.double_dispatch(:please_fail, Resolver) }
  end

  def test_double_dispatch
    resolver = Object.new
    instance = Dog.new

    result = instance.double_dispatch(:perform_for, Resolver)

    assert_equal [instance, []], result
  end

  def test_double_dispatch_with_more_arguments
    instance = Dog.new

    result = instance.double_dispatch(:perform_for, Resolver, 2, :other_arg)

    assert_equal [instance, [2, :other_arg]], result
  end

  def test_overwrite_dispatch_id
    Dog.dispatch_as :not_a_dog

    instance = Dog.new

    result = instance.double_dispatch(:perform_for, Resolver)

    assert_equal 'Not a dog', result

    Dog.dispatch_as :dog
  end

  def test_extension_by_class_name
    assert_equal 'human', Human.dispatch_id

    assert Human.new.double_dispatch(:test_for, Resolver)
  end
end
