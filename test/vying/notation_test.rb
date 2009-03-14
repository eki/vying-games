
require 'test/unit'
require 'vying'

class TestNotation < Test::Unit::TestCase
  include Vying

  def test_initialize
    g = Game.new TicTacToe
    n = Notation.new( g )

    assert_equal( g.object_id, n.game.object_id )
  end

  def test_to_move
    g = Game.new TicTacToe
    n = Notation.new( g )

    assert_equal( "a1", n.to_move( "a1" ) )
    assert_equal( "draw", n.to_move( "draw" ) )
    assert_equal( "anything really", n.to_move( "anything really" ) )
  end

  def test_translate
    g = Game.new TicTacToe
    n = Notation.new( g )

    assert_equal( "a1", n.translate( "a1", :x ) )
    assert_equal( "a1", n.translate( "a1", :o ) )
    assert_equal( "draw", n.translate( "draw", :x ) )
    assert_equal( "draw", n.translate( "draw", :o ) )
    assert_equal( "anything really", n.translate( "anything really", :black ) )
    assert_equal( "anything really", n.translate( "anything really", :white ) )
  end

  def test_sequence
    g = Game.new TicTacToe
    n = Notation.new( g )

    g << g.moves.first << g.moves.first << g.moves.first

    assert( g.sequence.first.kind_of?( String ) )
    assert( n.sequence.first.kind_of?( String ) )
    assert_equal( g.sequence, n.sequence )

    g << g.moves.first until g.final?

    assert( g.sequence.first.kind_of?( String ) )
    assert( n.sequence.first.kind_of?( String ) )
    assert_equal( g.sequence, n.sequence )
  end

  def test_moves
    g = Game.new TicTacToe
    n = Notation.new( g )

    assert_equal( g.moves, n.moves )
    assert_equal( g.moves( :x ), n.moves( :x ) )
    assert_equal( g.moves( :o ), n.moves( :o ) )

    g << g.moves.first

    assert_equal( g.moves, n.moves )
    assert_equal( g.moves( :x ), n.moves( :x ) )
    assert_equal( g.moves( :o ), n.moves( :o ) )

    g << g.moves.first until g.final?

    assert_equal( g.moves, n.moves )
    assert_equal( g.moves( :x ), n.moves( :x ) )
    assert_equal( g.moves( :o ), n.moves( :o ) )
  end

  def test_sealed_moves
    g = Game.new Footsteps
    n = Notation.new( g )

    assert_equal( g.moves, n.moves )
    assert_equal( g.moves( :left ), n.moves( :left ) )
    assert_equal( g.moves( :right ), n.moves( :right ) )

    g[:left] << g[:left].moves.first

    assert_equal( g.moves.first.class, n.moves.first.class )
    assert_equal( g.moves, n.moves )
    assert_equal( g.moves( :left ), n.moves( :left ) )
    assert_equal( g.moves( :right ), n.moves( :right ) )

    until g.final?
      g[:left]  << g[:left].moves.first  if g[:left].has_moves?
      g[:right] << g[:right].moves.first if g[:right].has_moves?
    end

    assert_equal( g.moves, n.moves )
    assert_equal( g.moves( :left ), n.moves( :left ) )
    assert_equal( g.moves( :right ), n.moves( :right ) )
  end

  def test_list
    Notation.list.each do |n|
      assert( n.ancestors.include?( Notation ) )
    end

    assert( Notation.list.length, Notation.list.uniq.length )
  end


end

