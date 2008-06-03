require 'test/unit'

require 'vying'
require 'vying/rules/rules_test'

class TestLinesOfAction < Test::Unit::TestCase
  include RulesTests

  def rules
    LinesOfAction
  end

  def test_info
    assert_equal( "Lines of Action", rules.name )
  end

  def test_players
    assert_equal( [:black,:white], rules.new.players )
  end

  def test_initialize       # Need to be more thorough here
    g = Game.new( rules )
    assert_equal( :black, g.turn )
    assert_equal( 12, g.board.occupied[:white].length )
    assert_equal( 12, g.board.occupied[:black].length )
  end

  def test_has_moves
    g = Game.new( rules )
    assert_equal( [:black], g.has_moves )
    g << g.moves.first
    assert_equal( [:white], g.has_moves )
    g << g.moves.first
    assert_equal( [:black], g.has_moves )
    g << g.moves.first
    assert_equal( [:white], g.has_moves )
    g << g.moves.first
    assert_equal( [:black], g.has_moves )
  end

  def test_moves
    g = Game.new( rules )

    assert_equal( 6, g.count( Coord[:a2], :n ) )
    assert_equal( 2, g.count( Coord[:a2], :e ) )
    assert_equal( 2, g.count( Coord[:a2], :se ) )

    g << "a2c2"

    assert_equal( 5, g.count( Coord[:a2], :n ) )
    assert_equal( 2, g.count( Coord[:a2], :e ) )
    assert_equal( 1, g.count( Coord[:a2], :se ) )

    assert_equal( 3, g.count( Coord[:c2], :n ) )
    assert_equal( 2, g.count( Coord[:c2], :e ) )
    assert_equal( 3, g.count( Coord[:c2], :se ) )

    g << "c1a3"

    assert_equal( 5, g.count( Coord[:a3], :n ) )
    assert_equal( 2, g.count( Coord[:a3], :e ) )
    assert_equal( 1, g.count( Coord[:a3], :ne ) )

    assert_equal( 5, g.count( Coord[:c1], :e ) )

    assert_equal( 12, g.board.occupied[:white].length )
    assert_equal( 11, g.board.occupied[:black].length )
  end
end

