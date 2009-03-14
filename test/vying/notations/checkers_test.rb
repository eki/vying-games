
require 'test/unit'
require 'vying'

class TestCheckersNotation < Test::Unit::TestCase

  def test_name
    assert_equal( :checkers_notation, Vying::CheckersNotation.notation_name )
  end

  def test_find
    assert_equal( Vying::CheckersNotation, 
                  Vying::Notation.find( :checkers_notation ) )
  end

  def test_to_move
    g = Game.new AmericanCheckers
    n = Vying::CheckersNotation.new( g )

    assert_equal( "b1c2", n.to_move( "1-6" ) )
    assert_equal( "a8b7", n.to_move( "29-25" ) )
    assert_equal( "f3e2", n.to_move( "11-7" ) )

    assert_equal( "undo", n.to_move( "undo" ) )
  end

  def test_translate
    g = Game.new AmericanCheckers
    n = Vying::CheckersNotation.new( g )

    assert_equal( "1-6", n.translate( "b1c2", :red ) )
    assert_equal( "1-6", n.translate( "b1c2", :white ) )

    assert_equal( "29-25", n.translate( "a8b7", :red ) )
    assert_equal( "29-25", n.translate( "a8b7", :white ) )

    assert_equal( "11-7", n.translate( "f3e2", :red ) )
    assert_equal( "11-7", n.translate( "f3e2", :white ) )

    assert_equal( "undo", n.translate( "undo", :red ) )
    assert_equal( "undo", n.translate( "undo", :white ) )
  end

  def test_sequence
    g = Game.new AmericanCheckers
    n = Vying::CheckersNotation.new( g )

    g << "f3e4" << "e6f5" << "e2f3" << "d7e6" << "d1e2" << "g6h5" << "e4g6"

    s = ["11-15", "23-19", "7-11", "26-23", "2-7", "24-20", "15-24"]

    # 15-24 is a capture, if we change the notation it should be 15x24

    assert( g.sequence.first.kind_of?( String ) )
    assert( n.sequence.first.kind_of?( String ) )
    assert_equal( s, n.sequence )
  end

  def test_moves
    g = Game.new AmericanCheckers
    n = Vying::CheckersNotation.new( g )

    s = ["9-14", "9-13", "10-15", "10-14", "11-16", "11-15", "12-16"]

    assert_equal( s, n.moves )
    assert_equal( s, n.moves( :red ) )
    assert_equal( [], n.moves( :white ) )
  end
end

