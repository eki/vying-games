require 'test/unit'

require 'vying'
require 'vying/rules/rules_test'

class TestAtaxx < Test::Unit::TestCase
  include RulesTests

  def rules
    Ataxx
  end

  def test_initialize
    g = Game.new( Ataxx )

    assert_equal( 7, g.board.width )
    assert_equal( 7, g.board.height )
    assert_equal( [:red, :red], g.board[:a1,:g7] )
    assert_equal( [:blue, :blue], g.board[:a7,:g1] )
    assert_equal( 2, g.board.occupied[:red].length )
    assert_equal( 2, g.board.occupied[:blue].length )
    assert_equal( :red, g.turn )
  end

  def test_moves
    g = Game.new( Ataxx )
    g.clear_blocks
    g.set_blocks( "" )

    moves = g.moves

    assert_equal( ["a1b1", "a1a2", "a1b2", 
                   "g7f6", "g7g6", "g7f7", 
                   "a1c1", "a1c2", "a1a3", "a1b3", "a1c3", 
                   "g7e5", "g7f5", "g7g5", "g7e6", "g7e7"].sort, moves.sort )

    g << g.moves.first until g.final?

    assert_not_equal( g.history.first, g.history.last )
  end

  def test_players
    g = Game.new( Ataxx )
    assert_equal( [:red,:blue], g.players )
    assert_equal( [:red,:blue], g.players )
  end

  def test_has_score
    g = Game.new( Ataxx )
    g.clear_blocks
    g.set_blocks( "" )

    g << "a1a2"

    assert( g.has_score? )
    assert_equal( 3, g.score( :red ) )
    assert_equal( 2, g.score( :blue ) )
  end

  def test_hash
    g1 = Game.new( Ataxx, 1234 )
    g2 = Game.new( Ataxx, 1234 )

    10.times do
      g1 << g1.moves.first
      g2 << g2.moves.first
    end

    assert( g1.history.last == g2.history.last )
    assert( g1.history.last.hash == g2.history.last.hash )
  end

end

