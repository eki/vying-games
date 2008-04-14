require 'test/unit'

require 'vying'
require 'vying/rules/rules_test'

class TestOthello < Test::Unit::TestCase
  include RulesTests

  def rules
    Othello
  end

  def test_initialize
    g = Game.new( Othello )

    b = OthelloBoard.new
    b[3,3] = b[4,4] = :white
    b[3,4] = b[4,3] = :black

    assert_equal( b, g.board )
    assert_equal( :black, g.turn )
  end

  def test_moves
    g = Game.new( Othello )
    moves = g.moves

    assert_equal( ['d3','c4','f5','e6'].sort, moves.sort )

    g << g.moves.first until g.final?

    assert_not_equal( g.history[0], g.history.last )
  end

  def test_players
    g = Game.new( Othello )
    assert_equal( [:black,:white], g.players )
    assert_equal( [:black,:white], g.players )
  end

  def test_has_score
    g = Game.new( Othello )
    g << g.moves.first

    assert( g.has_score? )
    assert_equal( 4, g.score( :black ) )
    assert_equal( 1, g.score( :white ) )
  end

  def test_hash
    g1 = Game.new Phutball
    g2 = Game.new Phutball

    10.times do
      g1 << g1.moves.first
      g2 << g2.moves.first
    end

    assert( g1.history.last == g2.history.last )
    assert( g1.history.last.hash == g2.history.last.hash )
  end
end

