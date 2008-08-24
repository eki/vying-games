require 'test/unit'

require 'vying'
require 'vying/rules/rules_test'

class TestFrames < Test::Unit::TestCase
  include RulesTests

  def rules
    Frames
  end

  def test_info
    assert_equal( "Frames", rules.name )
    assert( Frames.sealed_moves? )
  end

  def test_players
    assert_equal( [:black,:white], rules.new.players )
  end

  def test_initialize
    g = Game.new( rules )
    assert_equal( [:black, :white], g.has_moves )
    assert_equal( 19, g.board.width )
    assert_equal( 19, g.board.height )
    assert_equal( 19*19, g.board.empty_count )
  end

  def test_moves
    g = Game.new( rules )

    assert_equal( 19*19*2, g.moves.length )
    assert_equal( 19*19, g.moves( :black ).length )
    assert_equal( 19*19, g.moves( :white ).length )

    g.board.coords.each do |c|
      assert( g[:black].move?( c ) )
      assert( g[:white].move?( c ) )
      assert( g.move?( c, :black ) )
      assert( g.move?( c, :white ) )
    end

    g[:black] << "n9"

    assert_equal( [:white], g.has_moves )

    assert_equal( 19*19, g.moves.length )
    assert_equal( 0, g.moves( :black ).length )
    assert_equal( 19*19, g.moves( :white ).length )

    g[:white] << "i2"

    assert_equal( [:black, :white], g.has_moves )

    assert_equal( 19*19*2-4, g.moves.length )
    assert_equal( 19*19-2, g.moves( :black ).length )
    assert_equal( 19*19-2, g.moves( :white ).length )

    assert( ! g.move?( "black_n9" ) )
    assert( ! g.move?( "white_n9" ) )
    assert( ! g.move?( "black_i2" ) )
    assert( ! g.move?( "white_i2" ) )
  end

end

