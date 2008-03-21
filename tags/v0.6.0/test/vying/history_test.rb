require 'test/unit'

require 'vying'

class TestHistory < Test::Unit::TestCase
  def test_initialize
    h = History.new( TicTacToe.new )
    assert_equal( [], h.sequence )
    assert_equal( [TicTacToe.new], h.positions )
    assert_equal( 1, h.length )
    assert_equal( TicTacToe.new, h.first )
    assert_equal( TicTacToe.new, h.last )
  end

  def test_append
    h = History.new( TicTacToe.new )
    h << "a1"
    assert_equal( ["a1"], h.sequence )
    assert_equal( 2, h.length )
    assert_equal( TicTacToe.new, h.first )
    assert_equal( TicTacToe.new.apply!( "a1" ), h.last )
  end

  def test_removal_01
    h = History.new( TicTacToe.new )
    h << "a1" << "a2" << "a3"
    p = h[2]
    h.positions[2] = nil

    assert_equal( nil, h.positions[2] )
    assert_equal( p, h[2] )
    assert_equal( p, h.positions[2] )
  end

  def test_removal_01
    h = History.new( TicTacToe.new )
    h << "a1" << "a2" << "a3"
    p2, p3  = h[2], h[3]
    h.positions[2], h.positions[3] = nil, nil

    assert_equal( 4, h.length )

    assert_equal( nil, h.positions[2] )
    assert_equal( nil, h.positions[3] )
    assert_equal( p3, h[3] )
    assert_equal( p2, h[2] )
    assert_equal( p3, h.positions[3] )
    assert_equal( p2, h.positions[2] )
  end

  def test_serialize_01
    h = History.new( TicTacToe.new )
    h << "a1" << "a2" << "a3"
    assert_equal( h, Marshal::load( Marshal::dump( h ) ) )
  end

  def test_serialize_02
    h = History.new( TicTacToe.new )
    h << "a1" << "a2" << "a3" << "b1" << "b2" << "b3" << "c2" << "c1"
    h2 = Marshal::load( Marshal::dump( h ) )
    assert_equal( h, h2 )
    assert_equal( nil, h2.positions[1] )
    assert_equal( h[1], h2[1] )
  end


end

