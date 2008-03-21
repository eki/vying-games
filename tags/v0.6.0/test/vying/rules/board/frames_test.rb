require 'test/unit'

require 'vying'
require 'vying/rules/rules_test'

class TestFrames < Test::Unit::TestCase
  include RulesTests

  def rules
    Frames
  end

  def test_info
    assert_equal( "Frames", Frames.info[:name] )
  end

  def test_players
    assert_equal( [:black,:white], Frames.players )
    assert_equal( [:black,:white], Frames.new.players )
  end

  def test_initialize
    g = Game.new( Frames )
    assert_equal( [:black, :white], g.has_moves )
    assert_equal( 19, g.board.width )
    assert_equal( 19, g.board.height )
    assert_equal( 19*19, g.board.empty_count )
  end

  def test_moves
    g = Game.new( Frames )

    assert_equal( 19*19*2, g.moves.length )
    assert_equal( 19*19, g.moves( :black ).length )
    assert_equal( 19*19, g.moves( :white ).length )

    g.board.coords.each do |c|
      assert( g.move?( "black_#{c}" ) )
      assert( g.move?( "white_#{c}" ) )
      assert( g.move?( "black_#{c}", :black ) )
      assert( g.move?( "white_#{c}", :white ) )
    end

    g << "black_n9"

    assert_equal( [:white], g.has_moves )

    assert_equal( 19*19, g.moves.length )
    assert_equal( 0, g.moves( :black ).length )
    assert_equal( 19*19, g.moves( :white ).length )

    g << "white_i2"

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

