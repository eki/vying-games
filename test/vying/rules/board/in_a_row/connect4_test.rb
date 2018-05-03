require_relative '../../../../test_helper'

class TestConnect4 < Minitest::Test
  include RulesTests

  def rules
    Connect4
  end

  def test_info
    assert_equal( "Connect Four", rules.name )
  end

  def test_players
    assert_equal( [:red,:blue], rules.new.players )
  end

  def test_init
    g = Game.new( rules )
    assert_equal( Board.rect( 7, 6 ), g.board )
    assert_equal( :red, g.turn )
  end

  def test_moves
    g = Game.new( rules )
    moves = g.moves

    assert_equal( 'a6', moves[0] )
    assert_equal( 'b6', moves[1] )
    assert_equal( 'c6', moves[2] )
    assert_equal( 'd6', moves[3] )
    assert_equal( 'e6', moves[4] )
    assert_equal( 'f6', moves[5] )
    assert_equal( 'g6', moves[6] )

    g << g.moves.first until g.final?

    refute_equal( g.history[0], g.history.last )

    assert_equal( 42-19, g.board.empty_count )
    assert_equal( 10, g.board.count( :red ) )
    assert_equal( 9, g.board.count( :blue ) )
  end

  def test_game01
    # This game is going to be a win for Red (vertical)
    g = play_sequence [:g6,:a6,:g5,:b6,:g4,:c6,:g3]

    assert( !g.draw? )
    assert( g.winner?( :red ) )
    assert( !g.loser?( :red ) )
    assert( !g.winner?( :blue ) )
    assert( g.loser?( :blue ) )
  end

  def test_game02
    # This game is going to be a win for Blue (diagonal)
    g = play_sequence [:b6,:a6,:c6,:b5,:c5,:c4,:d6,:d5,:d4,:d3]

    assert( !g.draw? )
    assert( !g.winner?( :red ) )
    assert( g.loser?( :red ) )
    assert( g.winner?( :blue ) )
    assert( !g.loser?( :blue ) )
  end

  def test_game03
    # This game is going to be a win for Blue (diagonal)
    g = play_sequence [:d6,:e6,:c6,:d5,:c5,:c4,:b6,:b5,:b4,:b3]

    assert( !g.draw? )
    assert( !g.winner?( :red ) )
    assert( g.loser?( :red ) )
    assert( g.winner?( :blue ) )
    assert( !g.loser?( :blue ) )
  end

  def test_game04
    # This game is going to be a draw
    g = play_sequence [:a6,:a5,:a4,:a3,:a2,:a1,:b6,:b5,:b4,:b3,:b2,:b1,:d6,
                       :c6,:c5,:c4,:c3,:c2,:c1,:d5,:d4,:d3,:d2,:d1,:e6,:e5,
                       :e4,:e3,:e2,:e1,:g6,:f6,:f5,:f4,:f3,:f2,:f1,:g5,:g4,
                       :g3,:g2,:g1]

    assert( g.draw? )
    assert( !g.winner?( :red ) )
    assert( !g.loser?( :red ) )
    assert( !g.winner?( :blue ) )
    assert( !g.loser?( :blue ) )
  end

  def test_game05
    # This game is going to be a win for Blue (horizontal 5-in-a-row)
    g = play_sequence [:g6,:a6,:a5,:c6,:c5,:d6,:d5,:e6,:e5,:b6]

    assert( !g.draw? )
    assert( !g.winner?( :red ) )
    assert( g.loser?( :red ) )
    assert( g.winner?( :blue ) )
    assert( !g.loser?( :blue ) )
  end

end

