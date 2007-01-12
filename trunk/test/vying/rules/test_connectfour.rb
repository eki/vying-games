require 'test/unit'

require 'vying'
require 'vying/rules/test_rules'

class TestConnectFour < Test::Unit::TestCase
  def test_init
    g = Game.new( ConnectFour )
    assert_equal( Board.new( 7, 6 ), g.board )
    assert_equal( :red, g.turn )
  end

  def test_dup
    pos = ConnectFour.new
    pos2 = pos.apply( :a6 )
    assert_not_equal( pos.unused_ops, pos2.unused_ops )
  end

  def test_ops
    g = Game.new( ConnectFour )
    ops = g.ops

    assert_equal( 'a6', ops[0] )
    assert_equal( 'b6', ops[1] )
    assert_equal( 'c6', ops[2] )
    assert_equal( 'd6', ops[3] )
    assert_equal( 'e6', ops[4] )
    assert_equal( 'f6', ops[5] )
    assert_equal( 'g6', ops[6] )

    while ops = g.ops do
      g << ops[0]
    end

    assert_not_equal( g.history[0], g.history.last )

    assert_equal( 42-19, g.board.count( nil ) )
    assert_equal( 10, g.board.count( :red ) )
    assert_equal( 9, g.board.count( :blue ) )
  end

  def test_players
    g = Game.new( ConnectFour )
    assert_equal( [:red,:blue], g.players )
    assert_equal( [:red,:blue], g.players )
  end

  def test_game01
    # This game is going to be a win for Red (vertical)
    g = Game.new( ConnectFour )
    g << [:g6,:a6,:g5,:b6,:g4,:c6]
    assert( !g.final? )
    g << :g3
    assert( g.final? )

    assert( !g.draw? )
    assert( g.winner?( :red ) )
    assert( !g.loser?( :red ) )
    assert( !g.winner?( :blue ) )
    assert( g.loser?( :blue ) )

    assert_equal( 1, g.score( :red ) )
    assert_equal( -1, g.score( :blue ) )
  end

  def test_game02
    # This game is going to be a win for Blue (diagonal)
    g = Game.new( ConnectFour )
    g << [:b6,:a6,:c6,:b5,:c5,:c4,:d6,:d5,:d4]
    assert( !g.final? )
    g << :d3
    assert( g.final? )

    assert( !g.draw? )
    assert( !g.winner?( :red ) )
    assert( g.loser?( :red ) )
    assert( g.winner?( :blue ) )
    assert( !g.loser?( :blue ) )

    assert_equal( -1, g.score( :red ) )
    assert_equal( 1, g.score( :blue ) )
  end

  def test_game03
    # This game is going to be a win for Blue (diagonal)
    g = Game.new( ConnectFour )
    g << [:d6,:e6,:c6,:d5,:c5,:c4,:b6,:b5,:b4]
    assert( !g.final? )
    g << :b3
    assert( g.final? )

    assert( !g.draw? )
    assert( !g.winner?( :red ) )
    assert( g.loser?( :red ) )
    assert( g.winner?( :blue ) )
    assert( !g.loser?( :blue ) )

    assert_equal( -1, g.score( :red ) )
    assert_equal( 1, g.score( :blue ) )
  end

  def test_game04
    # This game is going to be a draw
    g = Game.new( ConnectFour )
    g << [:a6,:a5,:a4,:a3,:a2,:a1,:b6,:b5,:b4,:b3,:b2,:b1,:d6,:c6,:c5,:c4,:c3,
          :c2,:c1,:d5,:d4,:d3,:d2,:d1,:e6,:e5,:e4,:e3,:e2,:e1,:g6,:f6,:f5,:f4,
          :f3,:f2,:f1,:g5,:g4,:g3,:g2]
    assert( !g.final? )
    g << :g1
    assert( g.final? )

    assert( g.draw? )
    assert( !g.winner?( :red ) )
    assert( !g.loser?( :red ) )
    assert( !g.winner?( :blue ) )
    assert( !g.loser?( :blue ) )

    assert_equal( 0, g.score( :red ) )
    assert_equal( 0, g.score( :blue ) )
  end

  def test_game05
    # This game is going to be a win for Blue (horizontal 5-in-a-row)
    g = Game.new( ConnectFour )
    g << [:g6,:a6,:a5,:c6,:c5,:d6,:d5,:e6,:e5]
    assert( !g.final? )
    g << :b6
    assert( g.final? )

    assert( !g.draw? )
    assert( !g.winner?( :red ) )
    assert( g.loser?( :red ) )
    assert( g.winner?( :blue ) )
    assert( !g.loser?( :blue ) )

    assert_equal( -1, g.score( :red ) )
    assert_equal( 1, g.score( :blue ) )
  end

end

