require 'test/unit'

require 'vying'
require 'vying/rules/test_rules'

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

  def test_ops
    g = Game.new( Othello )
    ops = g.ops

    assert_equal( ['d3','c4','f5','e6'].sort, ops.sort )

    while ops = g.ops do
      g << ops[0]
    end

    assert_not_equal( g.history[0], g.history.last )
  end

  def test_players
    g = Game.new( Othello )
    assert_equal( [:black,:white], g.players )
    assert_equal( [:black,:white], g.players )
  end

end

