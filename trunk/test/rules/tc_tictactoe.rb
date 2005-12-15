$:.unshift File.join( File.dirname( __FILE__ ), "..", "lib" )

require "test/unit"
require "game"
require "rules/tictactoe"

class TestTicTacToe < Test::Unit::TestCase
  def test_init
    g = Game.new( TicTacToe )
    assert_equal( Board.new( 3, 3 ), g.board )
    assert_equal( Player.x, g.turn )
  end

  def test_ops
    g = Game.new( TicTacToe )
    ops = g.ops
    assert_equal( 'Place X', ops[0].name )

    assert_equal( 'a0', ops[0].short )
    assert_equal( 'b0', ops[1].short )
    assert_equal( 'c0', ops[2].short )
    assert_equal( 'a1', ops[3].short )
    assert_equal( 'b1', ops[4].short )
    assert_equal( 'c1', ops[5].short )
    assert_equal( 'a2', ops[6].short )
    assert_equal( 'b2', ops[7].short )
    assert_equal( 'c2', ops[8].short )

    while ops = g.ops do
      g << ops[0]
    end

    assert_not_equal( g.history[0], g.history.last )

    assert_equal( 2, g.board.count( Piece.empty ) )
    assert_equal( 4, g.board.count( Piece.x ) )
    assert_equal( 3, g.board.count( Piece.o ) )
  end

  def test_players
    g = Game.new( TicTacToe )
    assert_equal( [Player.x,Player.o], g.players )
    assert_equal( [Piece.x,Piece.o], g.players )
  end

  def test_game01
    # This game is going to be a win for X (diagonal)
    g = Game.new( TicTacToe )
    g << "c0" << "b0" << "b1" << "c1"
    assert( !g.final? )
    g << "a2"
    assert( g.final? )

    assert( !g.draw? )
    assert( g.winner?( Player.x ) )
    assert( !g.loser?( Player.x ) )
    assert( !g.winner?( Player.o ) )
    assert( g.loser?( Player.o ) )

    assert_equal( 1, g.score( Player.x ) )
    assert_equal( -1, g.score( Player.o ) )
  end

  def test_game02
    # This game is going to be a win for X (vertical)
    g = Game.new( TicTacToe )
    g << "c2" << "a0" << "c1" << "a1" << "b0"
    assert( !g.final? )
    g << "b1" << "c0"
    assert( g.final? )

    assert( !g.draw? )
    assert( g.winner?( Player.x ) )
    assert( !g.loser?( Player.x ) )
    assert( !g.winner?( Player.o ) )
    assert( g.loser?( Player.o ) )

    assert_equal( 1, g.score( Player.x ) )
    assert_equal( -1, g.score( Player.o ) )
  end

  def test_game03
    # This game is going to be a draw
    g = Game.new( TicTacToe )
    g << "a0" << "b0" << "a1" << "b1" << "b2" << "a2" << "c0" << "c1"
    assert( !g.final? )
    g << "c2"
    assert( g.final? )

    assert( g.draw? )
    assert( !g.winner?( Player.x ) )
    assert( !g.loser?( Player.x ) )
    assert( !g.winner?( Player.o ) )
    assert( !g.loser?( Player.o ) )

    assert_equal( 0, g.score( Player.x ) )
    assert_equal( 0, g.score( Player.o ) )
  end

  def test_game04
    # This game is going to be a win for O (horizontal)
    g = Game.new( TicTacToe )
    g << "a0" << "b0" << "a1" << "b1" << "c2"
    assert( !g.final? )
    g << "b2"
    assert( g.final? )

    assert( !g.draw? )
    assert( !g.winner?( Player.x ) )
    assert( g.loser?( Player.x ) )
    assert( g.winner?( Player.o ) )
    assert( !g.loser?( Player.o ) )

    assert_equal( -1, g.score( Player.x ) )
    assert_equal( 1, g.score( Player.o ) )
  end

  def test_game05
    # This game is going to be a win for O (diagonal)
    g = Game.new( TicTacToe )
    g << "a1" << "a0" << "c1" << "b1" << "a2"
    assert( !g.final? )
    g << "c2"
    assert( g.final? )

    assert( !g.draw? )
    assert( !g.winner?( Player.x ) )
    assert( g.loser?( Player.x ) )
    assert( g.winner?( Player.o ) )
    assert( !g.loser?( Player.o ) )

    assert_equal( -1, g.score( Player.x ) )
    assert_equal( 1, g.score( Player.o ) )
  end
end

