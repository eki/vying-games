require "test/unit"

require "vying/rules/pig"
require "vying/rules/test_rules"

class TestPig < Test::Unit::TestCase
  include RulesTests

  def rules
    Pig
  end

  def test_info
    assert_equal( "Pig", Pig.info[:name] )
  end

  def test_players
    assert_equal( [:a,:b], Pig.players )
    assert_equal( [:a,:b], Pig.new.players )
  end

  def test_initialize
    g = Game.new( Pig )
    assert_equal( Hash.new( 0 ), g.total )
    assert_equal( :a, g.turn )
    assert_equal( 0, g.score )
    assert_equal( false, g.rolling )
  end

  def test_has_ops
    g = Game.new( Pig )
    assert_equal( [:a], g.has_ops )
    g << :roll
    assert_equal( [:random], g.has_ops )
    g << 1
    assert_equal( [:b], g.has_ops )
    g << :pass
    assert_equal( [:a], g.has_ops )
  end

  def test_ops
    g = Game.new( Pig )
    ops = g.ops

    assert_equal( [:pass,:roll], ops )

    while ops = g.ops do
      g << [:roll, 1, :roll, 6, :roll, 5, :pass]
    end

    assert_not_equal( g.history[0], g.history.last )
  end
end

