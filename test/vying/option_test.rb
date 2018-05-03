
require_relative '../test_helper'

class TestOption < Minitest::Test
  include Vying

  def test_initialize
    opt = Option.new( :my_option, :default => 42, :values => [41,42,43] )

    assert_equal( :my_option, opt.name )
    assert_equal( 42, opt.default )
    assert_equal( [41,42,43], opt.values )

    assert_raises( RuntimeError ) do
      Option.new( :no_default, :values => [1,2,3] )
    end

    assert_raises( RuntimeError ) do
      Option.new( :no_values, :default => 4 )
    end

    assert_raises( RuntimeError ) do
      Option.new( :default_not_in_values, :default => 4, :values => [1,2,3] )
    end
  end

  def test_coerce
    opt_sym = Option.new( :opt_sym, :default => :a, :values => [:a,:b] )
    opt_s   = Option.new( :opt_s, :default => 'a', :values => ['a', 'b'] )
    opt_i   = Option.new( :opt_i, :default => 42, :values => [41,42,43] )
    opt_f   = Option.new( :opt_f, :default => 4.2, :values => [4.2,4.3,4.4] )
    opt_o   = Option.new( :opt_o, :default => Coord[:a1], 
                                  :values => [Coord[:a1], Coord[:b1]] )

    assert_equal( :a, opt_sym.coerce( "a" ) )
    assert_equal( 'a', opt_s.coerce( :a ) )
    assert_equal( 1, opt_i.coerce( "1" ) )
    assert_equal( 1.0, opt_f.coerce( "1.0" ) )
    assert_equal( Coord[:a1], opt_o.coerce( Coord[:a1] ) )
    assert_equal( :a1, opt_o.coerce( :a1 ) )
  end

  def test_validate
    opt_sym = Option.new( :opt_sym, :default => :a, :values => [:a,:b] )
    opt_s   = Option.new( :opt_s, :default => 'a', :values => ['a', 'b'] )
    opt_i   = Option.new( :opt_i, :default => 42, :values => [41,42,43] )
    opt_f   = Option.new( :opt_f, :default => 4.2, :values => [4.2,4.3,4.4] )
    opt_o   = Option.new( :opt_o, :default => Coord[:a1], 
                                  :values => [Coord[:a1], Coord[:b1]] )

    assert( opt_sym.validate( "a" ) )
    assert( opt_s.validate( :a ) )
    assert( opt_i.validate( "43" ) )
    assert( opt_f.validate( "4.2" ) )
    assert( opt_o.validate( Coord[:a1] ) )
    assert( opt_o.validate( :a1 ) )
  end

end

