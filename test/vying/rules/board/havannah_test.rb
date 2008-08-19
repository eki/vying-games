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

  def test_ring_01
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

  def test_ring_02
    g = play_sequence ["b6", "j11", "a5", "j10", "c6", "j9", 
                       "b4", "j8", "c5", "j7", "a4"]

    assert_equal( 1, g.groups[:blue].length )
    assert( g.groups[:blue].first.ring? )

    assert( !g.draw? )
    assert( g.winner?( :blue ) )
    assert( !g.loser?( :blue ) )
    assert( !g.winner?( :red ) )
    assert( g.loser?( :red ) )
  end

  def test_filled_ring_01
    g = play_sequence ["p16", "o8", "q17", "o9", "r18", "o10", "r17", "o11",
                       "q16", "o12", "q18", "o13", "p17"]
                       

    assert_equal( 1, g.groups[:blue].length )
    assert( g.groups[:blue].first.ring? )

    assert( !g.draw? )
    assert( g.winner?( :blue ) )
    assert( !g.loser?( :blue ) )
    assert( !g.winner?( :red ) )
    assert( g.loser?( :red ) )
  end

  def test_filled_ring_02
    g = play_sequence ["p17", "q17", "p16", "o9", "r18", "o10", "r17", "o11",
                       "q16", "o12", "q18"]
                       

    assert_equal( 1, g.groups[:blue].length )
    assert( g.groups[:blue].first.ring? )

    assert( !g.draw? )
    assert( g.winner?( :blue ) )
    assert( !g.loser?( :blue ) )
    assert( !g.winner?( :red ) )
    assert( g.loser?( :red ) )
  end

  def test_filled_ring_02
    g = Game.new rules

    g << ["s19", "o8", "s18", "o9", "r18", "o10", 
          "r19", "o11", "q18", "o12", "q19"]

    assert_equal( 1, g.groups[:blue].length )
    assert( ! g.groups[:blue].first.ring? )
  end


end

