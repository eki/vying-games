require "test/unit"

require "vying/rules/amazons"
require "vying/rules/test_rules"

class TestAmazons < Test::Unit::TestCase
  include RulesTests

  def rules
    Amazons
  end

  def test_info
    assert_equal( "Amazons", Amazons.info[:name] )
  end

  def test_players
    assert_equal( [:white,:black], Amazons.players )
    assert_equal( [:white,:black], Amazons.new.players )
  end

  def test_initialize       # Need to be more thorough here
    g = Game.new( Amazons )
    assert_equal( :white, g.turn )
    assert_equal( nil, g.lastc )
  end

  def test_has_ops
    g = Game.new( Amazons )
    assert_equal( [:white], g.has_ops )
    g << g.ops.first
    assert_equal( [:white], g.has_ops )
    g << g.ops.first
    assert_equal( [:black], g.has_ops )
    g << g.ops.first
    assert_equal( [:black], g.has_ops )
    g << g.ops.first
    assert_equal( [:white], g.has_ops )
  end

  def test_ops
    g = Game.new( Amazons )
    ops = g.ops

    assert_equal( "a4a3", ops[0] )
    assert_equal( "a4a2", ops[1] )
    assert_equal( "a4a1", ops[2] )
    assert_equal( "a4b4", ops[3] )
    assert_equal( "j4f8", ops[-2] )
    assert_equal( "j4e9", ops[-1] )

    while ops = g.ops do
      g << g.ops.first
    end

    assert_not_equal( g.history[0], g.history.last )
  end
end

