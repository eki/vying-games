require 'test/unit'

require 'vying'
require 'vying/rules/rules_test'

class TestMakyek < Test::Unit::TestCase
  include RulesTests

  def rules
    Makyek
  end

  def test_info
    assert_equal( "Mak-yek", Makyek.info[:name] )
  end

  def test_players
    assert_equal( [:white,:black], Makyek.players )
    assert_equal( [:white,:black], Makyek.new.players )
  end

  def test_initialize       # Need to be more thorough here
    g = Game.new( Makyek )
    assert_equal( :white, g.turn )
    assert_equal( nil, g.lastc )
  end

  def test_has_moves
    g = Game.new( Makyek )
    assert_equal( [:white], g.has_moves )
    g << g.moves.first
    assert_equal( [:black], g.has_moves )
  end

  def test_moves
    g = Game.new( Makyek )
    moves = g.moves

    assert_equal( "a1a2", moves[0] )
    assert_equal( "b1b2", moves[1] )
    assert_equal( "c1c2", moves[2] )
    assert_equal( "h3h5", moves[-1] )

    while moves = g.moves do
      g << g.moves.first
    end

    assert_not_equal( g.history[0], g.history.last )
  end
end

