require 'test/unit'

require 'vying'
require 'vying/rules/rules_test'

class TestPig < Test::Unit::TestCase
  include RulesTests

  def rules
    Pig
  end

  def test_info
    assert_equal( "Pig", rules.name )
  end

  def test_players
    assert_equal( [:a,:b], rules.new.players )
  end

  def test_initialize
    g = Game.new( rules )
    assert_equal( Hash.new( 0 ), g.total )
    assert_equal( :a, g.turn )
    assert_equal( false, g.rolling )
  end

  def test_has_moves
    g = Game.new( rules )
    assert_equal( [:a], g.has_moves )
    g << :roll
    assert_equal( [:random], g.has_moves )
    g << 1
    assert_equal( [:b], g.has_moves )
    g << :pass
    assert_equal( [:a], g.has_moves )
  end

  def test_moves
    g = Game.new( rules )
    moves = g.moves

    assert_equal( ['pass','roll'], moves )

    g << [:roll, 1, :roll, 6, :roll, 5, :pass] until g.final?

    assert_not_equal( g.history[0], g.history.last )
  end

  def test_current_score
    g = Game.new( rules )

    g << [:roll, 3, :roll, 5]
    assert_equal( 8, g.current_score )
    assert_equal( 0, g.score( :a ) )

    g << :pass
    assert_equal( 0, g.current_score )
    assert_equal( 8, g.score( :a ) )

    g << [:roll, 2, :roll, 5]
    assert_equal( 7, g.current_score )
    assert_equal( 0, g.score( :b ) )

    g << [:roll, 1]
    assert_equal( 0, g.current_score )
    assert_equal( 0, g.score( :b ) )
  end

  def test_game
    g = Game.new( rules )

    srand 12345678
    g << g.moves[rand( g.moves.length )] until g.final?

    assert( !g.draw? )

    g.players.each do |p|
      assert( g.score( p ) >= 100 ) if g.winner?( p )
      assert( g.score( p )  < 100 ) if g.loser?( p )
    end

    assert( g.player_names.select { |p| g.winner?( p ) }.length == 1 )
    assert( g.player_names.select { |p| g.loser?(  p ) }.length == 1 )
  end
end

