require 'test/unit'

require 'vying'
require 'vying/rules/rules_test'

class TestHavannah < Test::Unit::TestCase
  include RulesTests

  def rules
    Havannah
  end

  def test_info
    assert_equal( "Havannah", rules.name )
  end

  def test_players
    assert_equal( [:blue,:red], rules.players )
    assert_equal( [:blue,:red], rules.new.players )
  end

  def test_initialize       # Need to be more thorough here
    g = Game.new( rules )
    assert_equal( :blue, g.turn )
  end

  def test_has_moves
    g = Game.new( rules )
    assert_equal( [:blue], g.has_moves )
    g << g.moves.first
    assert_equal( [:red], g.has_moves )
  end

  def test_ring
    g = play_sequence ["d6", "j11", "c5", "j10", "c4", "j9", 
                       "d4", "j8", "e5", "j7", "e6"]

    assert_equal( 1, g.groups[:blue].length )
    assert( g.groups[:blue].first.ring? )

    assert( !g.draw? )
    assert( g.winner?( :blue ) )
    assert( !g.loser?( :blue ) )
    assert( !g.winner?( :red ) )
    assert( g.loser?( :red ) )
  end


end

