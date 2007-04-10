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

  def test_has_ops
    g = Game.new( Makyek )
    assert_equal( [:white], g.has_ops )
    g << g.ops.first
    assert_equal( [:black], g.has_ops )
  end

  def test_ops
    g = Game.new( Makyek )
    ops = g.ops

    assert_equal( "a1a2", ops[0] )
    assert_equal( "b1b2", ops[1] )
    assert_equal( "c1c2", ops[2] )
    assert_equal( "h3h5", ops[-1] )

    while ops = g.ops do
      g << g.ops.first
    end

    assert_not_equal( g.history[0], g.history.last )
  end
end

