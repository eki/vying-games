require 'test/unit'

require 'vying'
require 'vying/rules/rules_test'

class TestTicTacToe < Test::Unit::TestCase
  def test_init
    g = Game.new( TicTacToe )
    assert_equal( Board.new( 3, 3 ), g.board )
    assert_equal( :x, g.turn )
  end

  def test_moves
    g = Game.new( TicTacToe )
    moves = g.moves

    assert_equal( 'a1', moves[0] )
    assert_equal( 'b1', moves[1] )
    assert_equal( 'c1', moves[2] )
    assert_equal( 'a2', moves[3] )
    assert_equal( 'b2', moves[4] )
    assert_equal( 'c2', moves[5] )
    assert_equal( 'a3', moves[6] )
    assert_equal( 'b3', moves[7] )
    assert_equal( 'c3', moves[8] )

    g << g.moves.first until g.final?

    assert_not_equal( g.history[0], g.history.last )

    assert_equal( 2, g.board.empty_count )
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
  end
end

