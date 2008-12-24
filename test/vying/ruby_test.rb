
require 'test/unit'
require 'vying'

class TestRuby < Test::Unit::TestCase
  def test_nest_const_defined
    assert( Module.nested_const_defined?( "Test" ) )
    assert( Module.nested_const_defined?( "Test::Unit" ) )
    assert( Module.nested_const_defined?( "Test::Unit::TestCase" ) )
    assert( ! Module.nested_const_defined?( "Test::Unit::FooBar" ) )

    assert( Object.nested_const_defined?( "Test" ) )
    assert( Object.nested_const_defined?( "Test::Unit" ) )
    assert( Object.nested_const_defined?( "Test::Unit::TestCase" ) )
    assert( ! Object.nested_const_defined?( "Test::Unit::FooBar" ) )

    assert( Kernel.nested_const_defined?( "Test" ) )
    assert( Kernel.nested_const_defined?( "Test::Unit" ) )
    assert( Kernel.nested_const_defined?( "Test::Unit::TestCase" ) )
    assert( ! Kernel.nested_const_defined?( "Test::Unit::FooBar" ) )

    assert( Test.nested_const_defined?( "Unit" ) )
    assert( Test.nested_const_defined?( "Unit::TestCase" ) )
    assert( ! Test.nested_const_defined?( "String" ) )

    assert( Test::Unit.nested_const_defined?( "TestCase" ) )
    assert( ! Test::Unit.nested_const_defined?( "String" ) )
  end

  def test_nest_const_get
    assert_equal( Test, Module.nested_const_get( "Test" ) )
    assert_equal( Test::Unit, Module.nested_const_get( "Test::Unit" ) )
    assert_equal( Test::Unit::TestCase, 
                  Module.nested_const_get( "Test::Unit::TestCase" ) )
    assert_equal( nil, Module.nested_const_get( "Test::Unit::FooBar" ) )

    assert_equal( Test, Object.nested_const_get( "Test" ) )
    assert_equal( Test::Unit, Object.nested_const_get( "Test::Unit" ) )
    assert_equal( Test::Unit::TestCase, 
                  Object.nested_const_get( "Test::Unit::TestCase" ) )
    assert_equal( nil, Object.nested_const_get( "Test::Unit::FooBar" ) )

    assert_equal( Test, Kernel.nested_const_get( "Test" ) )
    assert_equal( Test::Unit, Kernel.nested_const_get( "Test::Unit" ) )
    assert_equal( Test::Unit::TestCase, 
                  Kernel.nested_const_get( "Test::Unit::TestCase" ) )
    assert_equal( nil, Kernel.nested_const_get( "Test::Unit::FooBar" ) )

    assert_equal( Test::Unit, Test.nested_const_get( "Unit" ) )
    assert_equal( Test::Unit::TestCase, 
                  Test.nested_const_get( "Unit::TestCase" ) )
    assert_equal( nil, Test.nested_const_get( "String" ) )

    assert_equal( Test::Unit::TestCase, 
                  Test::Unit.nested_const_get( "TestCase" ) )
    assert_equal( nil, Test::Unit.nested_const_get( "String" ) )
  end
end

