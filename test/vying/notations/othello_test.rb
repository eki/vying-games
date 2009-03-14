
require 'test/unit'
require 'vying'

class TestOthelloNotation < Test::Unit::TestCase

  def test_name
    assert_equal( :othello_notation, Vying::OthelloNotation.notation_name )
  end

  def test_find
    assert_equal( Vying::OthelloNotation, 
                  Vying::Notation.find( :othello_notation ) )
  end

  def test_to_move
    g = Game.new Othello
    n = Vying::OthelloNotation.new( g )

    assert_equal( "c2", n.to_move( "C2" ) )
    assert_equal( "c2", n.to_move( "c2" ) )

    assert_equal( "undo", n.to_move( "undo" ) )
  end

  def test_translate
    g = Game.new Othello
    n = Vying::OthelloNotation.new( g )

    assert_equal( "C2", n.translate( "c2", :black ) )
    assert_equal( "c2", n.translate( "c2", :white ) )

    assert_equal( "A8", n.translate( "a8", :black ) )
    assert_equal( "a8", n.translate( "a8", :white ) )

    assert_equal( "F5", n.translate( "F5", :black ) )
    assert_equal( "f5", n.translate( "f5", :white ) )

    assert_equal( "undo", n.translate( "undo", :black ) )
    assert_equal( "undo", n.translate( "undo", :white ) )
  end

  def test_sequence
    g = Game.new Othello
    n = Vying::OthelloNotation.new( g )

    g << ["e6", "f6", "f5", "f4", "d3", "d6", "f3", "c5"]

    s = ["E6", "f6", "F5", "f4", "D3", "d6", "F3", "c5"]

    assert( g.sequence.first.kind_of?( String ) )
    assert( n.sequence.first.kind_of?( String ) )
    assert_equal( s, n.sequence )
  end

  def test_moves
    g = Game.new Othello
    n = Vying::OthelloNotation.new( g )

    assert_equal( :black, g.turn )

    assert_equal( [], n.moves( :white ) )
    assert_not_equal( [], n.moves )
    assert_not_equal( [], n.moves( :black ) )

    n.moves.each { |m| assert_equal( m, m.to_s.upcase ) }
    n.moves( :black ).each { |m| assert_equal( m, m.to_s.upcase ) }

    g << g.moves.first

    assert_equal( :white, g.turn )

    assert_equal( [], n.moves( :black ) )
    assert_not_equal( [], n.moves )
    assert_not_equal( [], n.moves( :white ) )

    n.moves.each { |m| assert_equal( m, m.to_s.downcase ) }
    n.moves( :white ).each { |m| assert_equal( m, m.to_s.downcase ) }
  end
end

