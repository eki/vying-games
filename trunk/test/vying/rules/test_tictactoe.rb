require "test/unit"

require "vying/rules/tictactoe"
require "vying/rules/test_rules"

class TestTicTacToe < Test::Unit::TestCase
  def test_init
    g = Game.new( TicTacToe )
    assert_equal( Board.new( 3, 3 ), g.board )
    assert_equal( :x, g.turn )
  end

  def test_ops
    g = Game.new( TicTacToe )
    ops = g.ops

    assert_equal( 'a1', ops[0] )
    assert_equal( 'b1', ops[1] )
    assert_equal( 'c1', ops[2] )
    assert_equal( 'a2', ops[3] )
    assert_equal( 'b2', ops[4] )
    assert_equal( 'c2', ops[5] )
    assert_equal( 'a3', ops[6] )
    assert_equal( 'b3', ops[7] )
    assert_equal( 'c3', ops[8] )

    while ops = g.ops do
      g << ops[0]
    end

    assert_not_equal( g.history[0], g.history.last )

    assert_equal( 2, g.board.count( nil ) )
    assert_equal( 4, g.board.count( :x ) )
    assert_equal( 3, g.board.count( :o ) )
  end

  def test_players
    g = Game.new( TicTacToe )
    assert_equal( [:x,:o], g.players )
    assert_equal( [:x,:o], g.players )
  end

  def test_game01
    # This game is going to be a win for X (diagonal)
    g = Game.new( TicTacToe )
    g << [:c1,:b1,:b2,:c2]
    assert( !g.final? )
    g << :a3
    assert( g.final? )

    assert( !g.draw? )
    assert( g.winner?( :x ) )
    assert( !g.loser?( :x ) )
    assert( !g.winner?( :o ) )
    assert( g.loser?( :o ) )

    assert_equal( 1, g.score( :x ) )
    assert_equal( -1, g.score( :o ) )
  end

  def test_game02
    # This game is going to be a win for X (vertical)
    g = Game.new( TicTacToe )
    g << [:c3,:a1,:c2,:a2,:b1]
    assert( !g.final? )
    g << [:b2,:c1]
    assert( g.final? )

    assert( !g.draw? )
    assert( g.winner?( :x ) )
    assert( !g.loser?( :x ) )
    assert( !g.winner?( :o ) )
    assert( g.loser?( :o ) )

    assert_equal( 1, g.score( :x ) )
    assert_equal( -1, g.score( :o ) )
  end

  def test_game03
    # This game is going to be a draw
    g = Game.new( TicTacToe )
    g << [:a1,:b1,:a2,:b2,:b3,:a3,:c1,:c2]
    assert( !g.final? )
    g << :c3
    assert( g.final? )

    assert( g.draw? )
    assert( !g.winner?( :x ) )
    assert( !g.loser?( :x ) )
    assert( !g.winner?( :o ) )
    assert( !g.loser?( :o ) )

    assert_equal( 0, g.score( :x ) )
    assert_equal( 0, g.score( :o ) )
  end

  def test_game04
    # This game is going to be a win for O (horizontal)
    g = Game.new( TicTacToe )
    g << [:a1,:b1,:a2,:b2,:c3]
    assert( !g.final? )
    g << :b3
    assert( g.final? )

    assert( !g.draw? )
    assert( !g.winner?( :x ) )
    assert( g.loser?( :x ) )
    assert( g.winner?( :o ) )
    assert( !g.loser?( :o ) )

    assert_equal( -1, g.score( :x ) )
    assert_equal( 1, g.score( :o ) )
  end

  def test_game05
    # This game is going to be a win for O (diagonal)
    g = Game.new( TicTacToe )
    g << [:a2,:a1,:c2,:b2,:a3]
    assert( !g.final? )
    g << :c3
    assert( g.final? )

    assert( !g.draw? )
    assert( !g.winner?( :x ) )
    assert( g.loser?( :x ) )
    assert( g.winner?( :o ) )
    assert( !g.loser?( :o ) )

    assert_equal( -1, g.score( :x ) )
    assert_equal( 1, g.score( :o ) )
  end
end

