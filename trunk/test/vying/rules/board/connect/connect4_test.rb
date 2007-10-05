require 'test/unit'

require 'vying'
require 'vying/rules/rules_test'

class TestConnect4 < Test::Unit::TestCase
  def test_init
    g = Game.new( Connect4 )
    assert_equal( Board.new( 7, 6 ), g.board )
    assert_equal( :red, g.turn )
  end

  def test_dup
    pos = Connect4.new
    pos2 = pos.apply( :a6 )
    assert_not_equal( pos.unused_moves, pos2.unused_moves )
  end

  def test_moves
    g = Game.new( Connect4 )
    moves = g.moves

    assert_equal( 'a6', moves[0] )
    assert_equal( 'b6', moves[1] )
    assert_equal( 'c6', moves[2] )
    assert_equal( 'd6', moves[3] )
    assert_equal( 'e6', moves[4] )
    assert_equal( 'f6', moves[5] )
    assert_equal( 'g6', moves[6] )

    g << g.moves.first until g.final?

    assert_not_equal( g.history[0], g.history.last )

    assert_equal( 42-19, g.board.count( nil ) )
    assert_equal( 10, g.board.count( :red ) )
    assert_equal( 9, g.board.count( :blue ) )
  end

  def test_players
    g = Game.new( Connect4 )
    assert_equal( [:red,:blue], g.players )
    assert_equal( [:red,:blue], g.players )
  end

  def test_game01
    # This game is going to be a win for Red (vertical)
    g = Game.new( Connect4 )
    g << [:g6,:a6,:g5,:b6,:g4,:c6]
    assert( !g.final? )
    g << :g3
    assert( g.final? )

    assert( !g.draw? )
    assert( g.winner?( :red ) )
    assert( !g.loser?( :red ) )
    assert( !g.winner?( :blue ) )
    assert( g.loser?( :blue ) )
  end

  def test_game02
    # This game is going to be a win for Blue (diagonal)
    g = Game.new( Connect4 )
    g << [:b6,:a6,:c6,:b5,:c5,:c4,:d6,:d5,:d4]
    assert( !g.final? )
    g << :d3
    assert( g.final? )

    assert( !g.draw? )
    assert( !g.winner?( :red ) )
    assert( g.loser?( :red ) )
    assert( g.winner?( :blue ) )
    assert( !g.loser?( :blue ) )
  end

  def test_game03
    # This game is going to be a win for Blue (diagonal)
    g = Game.new( Connect4 )
    g << [:d6,:e6,:c6,:d5,:c5,:c4,:b6,:b5,:b4]
    assert( !g.final? )
    g << :b3
    assert( g.final? )

    assert( !g.draw? )
    assert( !g.winner?( :red ) )
    assert( g.loser?( :red ) )
    assert( g.winner?( :blue ) )
    assert( !g.loser?( :blue ) )
  end

  def test_game04
    # This game is going to be a draw
    g = Game.new( Connect4 )
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
  end

  def test_game05
    # This game is going to be a win for Blue (horizontal 5-in-a-row)
    g = Game.new( Connect4 )
    g << [:g6,:a6,:a5,:c6,:c5,:d6,:d5,:e6,:e5]
    assert( !g.final? )
    g << :b6
    assert( g.final? )

    assert( !g.draw? )
    assert( !g.winner?( :red ) )
    assert( g.loser?( :red ) )
    assert( g.winner?( :blue ) )
    assert( !g.loser?( :blue ) )
  end

end

