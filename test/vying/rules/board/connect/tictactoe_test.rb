require 'test/unit'

require 'vying'
require 'vying/rules/rules_test'

class TestTicTacToe < Test::Unit::TestCase
  include RulesTests

  def rules
    TicTacToe 
  end

  def test_info
    assert_equal( "Tic Tac Toe", rules.name )
  end

  def test_players
    assert_equal( [:x,:o], rules.new.players )
  end

  def test_init
    g = Game.new( rules )
    assert_equal( Board.new( 3, 3 ), g.board )
    assert_equal( :x, g.turn )
  end

  def test_moves
    g = Game.new( rules )
    moves = g.moves

    assert_equal( 'a1', moves[0].to_s )
    assert_equal( 'b1', moves[1].to_s )
    assert_equal( 'c1', moves[2].to_s )
    assert_equal( 'a2', moves[3].to_s )
    assert_equal( 'b2', moves[4].to_s )
    assert_equal( 'c2', moves[5].to_s )
    assert_equal( 'a3', moves[6].to_s )
    assert_equal( 'b3', moves[7].to_s )
    assert_equal( 'c3', moves[8].to_s )

    g << g.moves.first until g.final?

    assert_not_equal( g.history[0], g.history.last )

    assert_equal( 2, g.board.empty_count )
    assert_equal( 4, g.board.count( :x ) )
    assert_equal( 3, g.board.count( :o ) )
  end

  def test_game01
    # This game is going to be a win for X (diagonal)
    g = play_sequence [:c1,:b1,:b2,:c2,:a3]

    assert( !g.draw? )
    assert( g.winner?( :x ) )
    assert( !g.loser?( :x ) )
    assert( !g.winner?( :o ) )
    assert( g.loser?( :o ) )
  end

  def test_game02
    # This game is going to be a win for X (vertical)
    g = play_sequence [:c3,:a1,:c2,:a2,:b1,:b2,:c1]

    assert( !g.draw? )
    assert( g.winner?( :x ) )
    assert( !g.loser?( :x ) )
    assert( !g.winner?( :o ) )
    assert( g.loser?( :o ) )
  end

  def test_game03
    # This game is going to be a draw
    g = play_sequence [:a1,:b1,:a2,:b2,:b3,:a3,:c1,:c2,:c3]

    assert( g.draw? )
    assert( !g.winner?( :x ) )
    assert( !g.loser?( :x ) )
    assert( !g.winner?( :o ) )
    assert( !g.loser?( :o ) )
  end

  def test_game04
    # This game is going to be a win for O (horizontal)
    g = play_sequence [:a1,:b1,:a2,:b2,:c3,:b3]

    assert( !g.draw? )
    assert( !g.winner?( :x ) )
    assert( g.loser?( :x ) )
    assert( g.winner?( :o ) )
    assert( !g.loser?( :o ) )
  end

  def test_game05
    # This game is going to be a win for O (diagonal)
    g = play_sequence [:a2,:a1,:c2,:b2,:a3,:c3]

    assert( !g.draw? )
    assert( !g.winner?( :x ) )
    assert( g.loser?( :x ) )
    assert( g.winner?( :o ) )
    assert( !g.loser?( :o ) )
  end
end

