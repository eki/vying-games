
require 'test/unit'
require 'vying'

class TestHistory < Test::Unit::TestCase
  def test_initialize
    h = History.new( TicTacToe, nil, TicTacToe.options )
    assert_equal( [], h.sequence )
    assert_equal( TicTacToe.new, h.last )
    assert_equal( 1, h.length )
    assert_equal( TicTacToe.new, h.first )
    assert_equal( TicTacToe.new, h.last )
  end

  def test_append
    h = History.new( TicTacToe, nil, TicTacToe.options )
    h.append( Move.new( "a1", TicTacToe.new.turn ) )
    assert_equal( ["a1"], h.sequence )
    assert_equal( [TicTacToe.new.turn], h.move_by )
    assert_equal( 2, h.length )
    assert_equal( TicTacToe.new, h.first )
    assert_equal( TicTacToe.new.apply!( "a1" ), h.last )
  end

  def test_removal_01
    h = History.new( TicTacToe, nil, TicTacToe.options )
    h.append( Move.new( "a1", TicTacToe.players.first ) )
    h.append( Move.new( "a2", TicTacToe.players.last ) )
    h.append( Move.new( "a3", TicTacToe.players.first ) )
    p = h[2]
    h.instance_variable_get( "@positions" )[2] = nil

    assert_equal( nil, h.instance_variable_get( "@positions" )[2] )
    assert_equal( p, h[2] )
    assert_equal( p, h.instance_variable_get( "@positions" )[2] )
  end

  def test_removal_02
    h = History.new( TicTacToe, nil, TicTacToe.options )
    h.append( Move.new( "a1", TicTacToe.players.first ) )
    h.append( Move.new( "a2", TicTacToe.players.last ) )
    h.append( Move.new( "a3", TicTacToe.players.first ) )
    p2, p3  = h[2], h[3]
    positions = h.instance_variable_get( "@positions" )
    positions[2], positions[3] = nil, nil

    assert_equal( 4, h.length )

    assert_equal( nil, positions[2] )
    assert_equal( nil, positions[3] )
    assert_equal( p3, h[3] )
    assert_equal( p2, h[2] )
    assert_equal( p3, positions[3] )
    assert_equal( p2, positions[2] )
  end

  def test_serialize_01
    h = History.new( TicTacToe, nil, TicTacToe.options )
    h.append( Move.new( "a1", TicTacToe.players.first ) )
    h.append( Move.new( "a2", TicTacToe.players.last ) )
    h.append( Move.new( "a3", TicTacToe.players.first ) )
    assert_equal( h, Marshal::load( Marshal::dump( h ) ) )
  end

  def test_serialize_02
    h = History.new( TicTacToe, nil, TicTacToe.options )
    h.append( Move.new( "a1", TicTacToe.players.first ) )
    h.append( Move.new( "a2", TicTacToe.players.last ) )
    h.append( Move.new( "a3", TicTacToe.players.first ) )
    h.append( Move.new( "b1", TicTacToe.players.first ) )
    h.append( Move.new( "b2", TicTacToe.players.last ) )
    h.append( Move.new( "b3", TicTacToe.players.first ) )
    h.append( Move.new( "c2", TicTacToe.players.last ) )
    h.append( Move.new( "c1", TicTacToe.players.first ) )
    h2 = Marshal::load( Marshal::dump( h ) )
    assert_equal( h, h2 )
    assert_equal( nil, h2.instance_variable_get( "@positions" )[1] )
    assert_equal( h[1], h2[1] )
  end

  def test_yaml
    h = History.new( TicTacToe, nil, TicTacToe.options )
    h.append( Move.new( "a1", TicTacToe.players.first ) )
    h.append( Move.new( "a2", TicTacToe.players.last ) )
    h.append( Move.new( "a3", TicTacToe.players.first ) )

    h2 = YAML.load( h.to_yaml )
    assert_equal( [], h2.instance_variable_get( "@positions" ) )
    assert_equal( h, h2 )
  end


end

