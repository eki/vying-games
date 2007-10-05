require 'test/unit'

require 'vying'
require 'vying/rules/rules_test'

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
    assert_equal( false, g.rolling )
  end

  def test_has_moves
    g = Game.new( Pig )
    assert_equal( [:a], g.has_moves )
    g << :roll
    assert_equal( [:random], g.has_moves )
    g << 1
    assert_equal( [:b], g.has_moves )
    g << :pass
    assert_equal( [:a], g.has_moves )
  end

  def test_moves
    g = Game.new( Pig )
    moves = g.moves

    assert_equal( ['pass','roll'], moves )

    g << [:roll, 1, :roll, 6, :roll, 5, :pass] until g.final?

    assert_not_equal( g.history[0], g.history.last )
  end
end

