require 'test/unit'

require 'vying/game'
require 'vying/rules/fifteen'
require 'vying/rules/test_rules'

class TestFifteen < Test::Unit::TestCase
  def test_init
    g = Game.new( Fifteen )
    assert_equal( (1..9).to_a, g.unused )
    assert_equal( [], g.a_list )
    assert_equal( [], g.b_list )
    assert_equal( :a, g.turn )
  end

  def test_ops
    g = Game.new( Fifteen )
    ops = g.ops

    assert_equal( 'a1', ops[0] )
    assert_equal( 'a2', ops[1] )
    assert_equal( 'a3', ops[2] )
    assert_equal( 'a4', ops[3] )
    assert_equal( 'a5', ops[4] )
    assert_equal( 'a6', ops[5] )
    assert_equal( 'a7', ops[6] )
    assert_equal( 'a8', ops[7] )
    assert_equal( 'a9', ops[8] )

    while ops = g.ops do
      g << ops[0]
    end

    assert_not_equal( g.history[0], g.history.last )

    assert_equal( [8,9], g.unused )
    assert_equal( [1,3,5,7], g.a_list )
    assert_equal( [2,4,6], g.b_list )
  end

  def test_players
    g = Game.new( Fifteen )
    assert_equal( [:a,:b], g.players )
  end

  def test_game01
    # This game is going to be a win for A
    g = Game.new( Fifteen )
    g << [:a2,:b3,:a7,:b4]
    assert( !g.final? )
    g << :a6
    assert( g.final? )

    assert( !g.draw? )
    assert( g.winner?( :a ) )
    assert( !g.loser?( :a ) )
    assert( !g.winner?( :b ) )
    assert( g.loser?( :b ) )

    assert_equal( 1, g.score( :a ) )
    assert_equal( -1, g.score( :b ) )
  end

  def test_game02
    # This game is going to be a win for B
    g = Game.new( Fifteen )
    g << [:a1,:b3,:a2,:b4,:a5]
    assert( !g.final? )
    g << :b8
    assert( g.final? )

    assert( !g.draw? )
    assert( !g.winner?( :a ) )
    assert( g.loser?( :a ) )
    assert( g.winner?( :b ) )
    assert( !g.loser?( :b ) )

    assert_equal( -1, g.score( :a ) )
    assert_equal( 1, g.score( :b ) )
  end

  def test_game03
    # This game is going to be a draw
    g = Game.new( Fifteen )
    g << [:a1,:b7,:a2,:b9,:a6,:b8,:a3,:b4]
    assert( !g.final? )
    g << :a5
    assert( g.final? )

    assert( g.draw? )
    assert( !g.winner?( :a ) )
    assert( !g.loser?( :a ) )
    assert( !g.winner?( :b ) )
    assert( !g.loser?( :b ) )

    assert_equal( 0, g.score( :a ) )
    assert_equal( 0, g.score( :a ) )
  end
end

