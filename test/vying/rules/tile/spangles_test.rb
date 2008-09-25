require 'test/unit'

require 'vying'
require 'vying/rules/rules_test'

class TestSpangles < Test::Unit::TestCase
  include RulesTests

  def rules
    Spangles
  end

  def test_info
    assert_equal( "Spangles", rules.name )
  end

  def test_players
    assert_equal( [:black,:white], rules.new.players )
  end

  def test_init
    g = Game.new( rules )

    assert_equal( :black, g.turn )
    assert_equal( [Coord[0,0]], g.board.occupied( :white ) )
    assert_equal( [], g.board.occupied( :black ) )
  end

  def test_has_score
    g = Game.new( rules )
    assert( !g.has_score? )
  end

  def test_has_moves
    g = Game.new( rules )
    assert_equal( [:black], g.has_moves )
    g << g.moves.first
    assert_equal( [:white], g.has_moves )
  end
end

