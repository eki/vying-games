
require "test/unit"
require "rules/connectfour/connectfour"

class TestConnectFourBoard < Test::Unit::TestCase
  def test_drop
    b = ConnectFourBoard.new( 3, 3 )
    s = "rrr\nrrr\nrrr\n"

    3.times do |x|
      b.drop( x, Piece.red ) while b.drop?( x )
    end

    assert_equal( s, b.to_s )
  end
end

class TestConnectFour < Test::Unit::TestCase
  def test_init
    g = Game.new( ConnectFour )
    assert_equal( ConnectFourBoard.new( 7, 6 ), g.board )
    assert_equal( Player.red, g.turn )
  end

  def test_ops
    g = Game.new( ConnectFour )
    ops = g.ops
    assert_equal( 'Drop', ops[0].name )

    assert_equal( 'r0', ops[0].short )
    assert_equal( 'r1', ops[1].short )
    assert_equal( 'r2', ops[2].short )
    assert_equal( 'r3', ops[3].short )
    assert_equal( 'r4', ops[4].short )
    assert_equal( 'r5', ops[5].short )
    assert_equal( 'r6', ops[6].short )

    while ops = g.ops do
      g << ops[0]
    end

    assert_not_equal( g.history[0], g.history.last )

    assert_equal( 42-19, g.board.count( nil ) )
    assert_equal( 10, g.board.count( Piece.red ) )
    assert_equal( 9, g.board.count( Piece.blue ) )
  end

  def test_players
    g = Game.new( ConnectFour )
    assert_equal( [Player.red,Player.blue], g.players )
    assert_equal( [Piece.red,Piece.blue], g.players )
  end

  def test_game01
    # This game is going to be a win for Red (vertical)
    g = Game.new( ConnectFour )
    g << "r6" << "b0" << "r6" << "b1" << "r6" << "b2"
    assert( !g.final? )
    g << "r6"
    assert( g.final? )

    assert( !g.draw? )
    assert( g.winner?( Player.red ) )
    assert( !g.loser?( Player.red ) )
    assert( !g.winner?( Player.blue ) )
    assert( g.loser?( Player.blue ) )

    assert_equal( 1, g.score( Player.red ) )
    assert_equal( -1, g.score( Player.blue ) )
  end

  def test_game02
    # This game is going to be a win for Blue (diagonal)
    g = Game.new( ConnectFour )
    g << "r1" << "b0" << "r2" << "b1" << "r2" << "b2" << "r3" << "b3" << "r3"
    assert( !g.final? )
    g << "b3"
    assert( g.final? )

    assert( !g.draw? )
    assert( !g.winner?( Player.red ) )
    assert( g.loser?( Player.red ) )
    assert( g.winner?( Player.blue ) )
    assert( !g.loser?( Player.blue ) )

    assert_equal( -1, g.score( Player.red ) )
    assert_equal( 1, g.score( Player.blue ) )
  end

  def test_game03
    # This game is going to be a win for Blue (diagonal)
    g = Game.new( ConnectFour )
    g << "r3" << "b4" << "r2" << "b3" << "r2" << "b2" << "r1" << "b1" << "r1"
    assert( !g.final? )
    g << "b1"
    assert( g.final? )

    assert( !g.draw? )
    assert( !g.winner?( Player.red ) )
    assert( g.loser?( Player.red ) )
    assert( g.winner?( Player.blue ) )
    assert( !g.loser?( Player.blue ) )

    assert_equal( -1, g.score( Player.red ) )
    assert_equal( 1, g.score( Player.blue ) )
  end

  def test_game04
    # This game is going to be a draw
    g = Game.new( ConnectFour )
    g << "r0" << "b0" << "r0" << "b0" << "r0" << "b0"
    g << "r1" << "b1" << "r1" << "b1" << "r1" << "b1"
    g << "r3" << "b2" << "r2" << "b2" << "r2" << "b2"
    g << "r2" << "b3" << "r3" << "b3" << "r3" << "b3"
    g << "r4" << "b4" << "r4" << "b4" << "r4" << "b4"
    g << "r6" << "b5" << "r5" << "b5" << "r5" << "b5"
    g << "r5" << "b6" << "r6" << "b6" << "r6"
    assert( !g.final? )
    g << "b6"
    assert( g.final? )

    assert( g.draw? )
    assert( !g.winner?( Player.red ) )
    assert( !g.loser?( Player.red ) )
    assert( !g.winner?( Player.blue ) )
    assert( !g.loser?( Player.blue ) )

    assert_equal( 0, g.score( Player.red ) )
    assert_equal( 0, g.score( Player.blue ) )
  end

end

