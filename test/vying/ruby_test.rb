
# frozen_string_literal: true

require_relative '../test_helper'

class TestRuby < Minitest::Test
  def test_nest_const_defined
    assert(Module.nested_const_defined?('Vying'))
    assert(Module.nested_const_defined?('Vying::Move'))
    assert(Module.nested_const_defined?('Vying::Move::Draw'))
    assert(!Module.nested_const_defined?('Vying::Move::FooBar'))

    assert(Object.nested_const_defined?('Vying'))
    assert(Object.nested_const_defined?('Vying::Move'))
    assert(Object.nested_const_defined?('Vying::Move::Draw'))
    assert(!Object.nested_const_defined?('Vying::Move::FooBar'))

    assert(Kernel.nested_const_defined?('Vying'))
    assert(Kernel.nested_const_defined?('Vying::Move'))
    assert(Kernel.nested_const_defined?('Vying::Move::Draw'))
    assert(!Kernel.nested_const_defined?('Vying::Move::FooBar'))

    assert(Vying.nested_const_defined?('Move'))
    assert(Vying.nested_const_defined?('Move::Draw'))
    assert(!Vying.nested_const_defined?('String'))

    assert(Vying::Move.nested_const_defined?('Draw'))
    assert(!Vying::Move.nested_const_defined?('String'))
  end

  def test_nest_const_get
    assert_equal(Vying, Module.nested_const_get('Vying'))
    assert_equal(Vying::Move, Module.nested_const_get('Vying::Move'))
    assert_equal(Vying::Move::Draw,
      Module.nested_const_get('Vying::Move::Draw'))
    assert_nil(Module.nested_const_get('Vying::Move::FooBar'))

    assert_equal(Vying, Object.nested_const_get('Vying'))
    assert_equal(Vying::Move, Object.nested_const_get('Vying::Move'))
    assert_equal(Vying::Move::Draw,
      Object.nested_const_get('Vying::Move::Draw'))
    assert_nil(Object.nested_const_get('Vying::Move::FooBar'))

    assert_equal(Vying, Kernel.nested_const_get('Vying'))
    assert_equal(Vying::Move, Kernel.nested_const_get('Vying::Move'))
    assert_equal(Vying::Move::Draw,
      Kernel.nested_const_get('Vying::Move::Draw'))
    assert_nil(Kernel.nested_const_get('Vying::Move::FooBar'))

    assert_equal(Vying::Move, Vying.nested_const_get('Move'))
    assert_equal(Vying::Move::Draw,
      Vying.nested_const_get('Move::Draw'))
    assert_nil(Vying.nested_const_get('String'))

    assert_equal(Vying::Move::Draw,
      Vying::Move.nested_const_get('Draw'))
    assert_nil(Vying::Move.nested_const_get('String'))
  end
end
