
require "test/unit"
require "rules/othello/othello"

class TestOthelloBoard < Test::Unit::TestCase
  def test_valid_ns
    b = OthelloBoard.new( 8, 8 )

    b[3,3] = Piece.black
    b[3,4] = Piece.white

    assert( b.valid?( Coord[3,5], Piece.black ) )
    assert( b.valid?( Coord[3,5], Piece.black, [:n] ) )
    assert( !b.valid?( Coord[3,5], Piece.white, [:n] ) )

    assert( b.valid?( Coord[3,2], Piece.white ) ) 
    assert( b.valid?( Coord[3,2], Piece.white, [:s] ) ) 
    assert( !b.valid?( Coord[3,2], Piece.black, [:s] ) ) 
  end

  def test_valid_ew
    b = OthelloBoard.new( 8, 8 )

    b[3,3] = Piece.black
    b[4,3] = Piece.white

    assert( b.valid?( Coord[5,3], Piece.black ) )
    assert( b.valid?( Coord[5,3], Piece.black, [:w] ) )
    assert( !b.valid?( Coord[5,3], Piece.white, [:w] ) )

    assert( b.valid?( Coord[2,3], Piece.white ) )
    assert( b.valid?( Coord[2,3], Piece.white, [:e] ) )
    assert( !b.valid?( Coord[2,3], Piece.black, [:e] ) )

    # check flip 2 in same direction

    b[5,3] = Piece.white

    assert( b.valid?( Coord[6,3], Piece.black ) )
    assert( b.valid?( Coord[6,3], Piece.black, [:w] ) )

    assert( !b.valid?( Coord[6,3], Piece.white, [:w] ) )
  end

  def test_valid_nw_se
    b = OthelloBoard.new( 8, 8 )

    b[0,0] = Piece.white
    b[1,1] = Piece.black
    b[3,3] = Piece.black
    b[4,4] = Piece.white

    assert( b.valid?( Coord[2,2], Piece.white ) )
    assert( b.valid?( Coord[2,2], Piece.white, [:nw] ) )
    assert( b.valid?( Coord[2,2], Piece.white, [:se] ) )
    assert( b.valid?( Coord[2,2], Piece.white, [:nw,:se] ) )
    assert( b.valid?( Coord[2,2], Piece.white, [:se,:nw] ) )

    assert( !b.valid?( Coord[2,2], Piece.black, [:se,:nw] ) )
  end

  def test_valid_ne_sw
    b = OthelloBoard.new( 8, 8 )

    b[7,0] = Piece.black
    b[6,1] = Piece.white
    b[5,2] = Piece.white
    b[3,4] = Piece.white
    b[2,5] = Piece.black

    assert( b.valid?( Coord[4,3], Piece.black ) )
    assert( b.valid?( Coord[4,3], Piece.black, [:ne] ) )
    assert( b.valid?( Coord[4,3], Piece.black, [:sw] ) )
    assert( b.valid?( Coord[4,3], Piece.black, [:ne,:sw] ) )
    assert( b.valid?( Coord[4,3], Piece.black, [:sw,:ne] ) )

    assert( !b.valid?( Coord[4,3], Piece.white, [:sw,:ne] ) )
  end

  def test_valid_empty
    b = OthelloBoard.new( 8, 8 )

    b[3,3] = Piece.black
    b[5,5] = Piece.white

    b.coords.each do |c| 
      assert( !b.valid?( c, Piece.black ) )
      assert( !b.valid?( c, Piece.white ) )
    end
  end

  def test_valid_edges
    b = OthelloBoard.new( 8, 8 )

    b[0,0] = b[3,0] = b[3,1] = b[7,0] = b[7,3] = Piece.black
    b[7,7] = b[3,7] = b[3,6] = b[0,7] = b[0,3] = Piece.white

    b.coords.each do |c| 
      assert( !b.valid?( c, Piece.black ) )
      assert( !b.valid?( c, Piece.white ) )
    end
  end

  def test_place_n
    b = OthelloBoard.new( 8, 8 )

    b[3,3] = Piece.black
    b[3,4] = Piece.white

    b.place( Coord[3,5], Piece.black )

    assert_equal( b[3,3], Piece.black )
    assert_equal( b[3,4], Piece.black )
    assert_equal( b[3,5], Piece.black )

    assert_equal( 8*8-3, b.count( nil ) )
  end

  def test_place_s
    b = OthelloBoard.new( 8, 8 )

    b[3,3] = Piece.black
    b[3,4] = Piece.white

    b.place( Coord[3,2], Piece.white )

    assert_equal( b[3,2], Piece.white )
    assert_equal( b[3,3], Piece.white )
    assert_equal( b[3,4], Piece.white )

    assert_equal( 8*8-3, b.count( nil ) )
  end

  def test_place_e
    b = OthelloBoard.new( 8, 8 )

    b[1,3] = Piece.black
    b[2,3] = Piece.black
    b[3,3] = Piece.black
    b[4,3] = Piece.white
    b[5,3] = Piece.white

    b.place( Coord[0,3], Piece.white )

    assert_equal( b[0,3], Piece.white )
    assert_equal( b[1,3], Piece.white )
    assert_equal( b[2,3], Piece.white )
    assert_equal( b[3,3], Piece.white )
    assert_equal( b[4,3], Piece.white )
    assert_equal( b[5,3], Piece.white )

    assert_equal( 8*8-6, b.count( nil ) )
  end

  def test_place_w
    b = OthelloBoard.new( 8, 8 )

    b[3,3] = Piece.black
    b[4,3] = Piece.white
    b[5,3] = Piece.white

    b.place( Coord[6,3], Piece.black )

    assert_equal( b[6,3], Piece.black )
    assert_equal( b[3,3], Piece.black )
    assert_equal( b[4,3], Piece.black )
    assert_equal( b[5,3], Piece.black )

    assert_equal( 8*8-4, b.count( nil ) )
  end

  def test_place_nw_se
    b = OthelloBoard.new( 8, 8 )

    b[0,0] = Piece.black
    b[1,1] = Piece.white
    b[2,2] = Piece.white
    b[4,4] = Piece.white
    b[5,5] = Piece.black

    b.place( Coord[3,3], Piece.black )

    assert_equal( b[0,0], Piece.black )
    assert_equal( b[1,1], Piece.black )
    assert_equal( b[2,2], Piece.black )
    assert_equal( b[3,3], Piece.black )
    assert_equal( b[4,4], Piece.black )
    assert_equal( b[5,5], Piece.black )

    assert_equal( 8*8-6, b.count( nil ) )
  end

  def test_place_ne_sw
    b = OthelloBoard.new( 8, 8 )

    b[7,0] = Piece.black
    b[6,1] = Piece.white
    b[5,2] = Piece.white
    b[3,4] = Piece.white
    b[2,5] = Piece.black

    b.place( Coord[4,3], Piece.black )

    assert_equal( b[7,0], Piece.black )
    assert_equal( b[6,1], Piece.black )
    assert_equal( b[5,2], Piece.black )
    assert_equal( b[4,3], Piece.black )
    assert_equal( b[3,4], Piece.black )
    assert_equal( b[2,5], Piece.black )

    assert_equal( 8*8-6, b.count( nil ) )
  end
end

class TestOthello < Test::Unit::TestCase
  def test_init
    g = Game.new( Othello )

    b = OthelloBoard.new( 8, 8 )
    b[3,3] = b[4,4] = Piece.white
    b[3,4] = b[4,3] = Piece.black

    assert_equal( b, g.board )
    assert_equal( Player.black, g.turn )
  end

  def test_ops
    g = Game.new( Othello )
    ops = g.ops

    assert_equal( 'd3', ops[0] )
    assert_equal( 'c4', ops[1] )
    assert_equal( 'f5', ops[2] )
    assert_equal( 'e6', ops[3] )

    while ops = g.ops do
      g << ops[0]
    end

    assert_not_equal( g.history[0], g.history.last )
  end

  def test_players
    g = Game.new( Othello )
    assert_equal( [Player.black,Player.white], g.players )
    assert_equal( [Piece.black,Piece.white], g.players )
  end

#  def test_game01
#    # This game is going to be a win for Red (vertical)
#    g = Game.new( Othello )
#    g << "r6" << "b0" << "r6" << "b1" << "r6" << "b2"
#    assert( !g.final? )
#    g << "r6"
#    assert( g.final? )
#
#    assert( !g.draw? )
#    assert( g.winner?( Player.black ) )
#    assert( !g.loser?( Player.black ) )
#    assert( !g.winner?( Player.white ) )
#    assert( g.loser?( Player.white ) )
#
#    assert_equal( 1, g.score( Player.black ) )
#    assert_equal( -1, g.score( Player.white ) )
#  end

#  def test_game02
#    # This game is going to be a win for Blue (diagonal)
#    g = Game.new( Othello )
#    g << "r1" << "b0" << "r2" << "b1" << "r2" << "b2" << "r3" << "b3" << "r3"
#    assert( !g.final? )
#    g << "b3"
#    assert( g.final? )
#
#    assert( !g.draw? )
#    assert( !g.winner?( Player.black ) )
#    assert( g.loser?( Player.black ) )
#    assert( g.winner?( Player.white ) )
#    assert( !g.loser?( Player.white ) )
#
#    assert_equal( -1, g.score( Player.black ) )
#    assert_equal( 1, g.score( Player.white ) )
#  end

#  def test_game03
#    # This game is going to be a win for Blue (diagonal)
#    g = Game.new( Othello )
#    g << "r3" << "b4" << "r2" << "b3" << "r2" << "b2" << "r1" << "b1" << "r1"
#    assert( !g.final? )
#    g << "b1"
#    assert( g.final? )
#
#    assert( !g.draw? )
#    assert( !g.winner?( Player.black ) )
#    assert( g.loser?( Player.black ) )
#    assert( g.winner?( Player.white ) )
#    assert( !g.loser?( Player.white ) )
#
#    assert_equal( -1, g.score( Player.black ) )
#    assert_equal( 1, g.score( Player.white ) )
#  end

#  def test_game04
#    # This game is going to be a draw
#    g = Game.new( Othello )
#    g << "r0" << "b0" << "r0" << "b0" << "r0" << "b0"
#    g << "r1" << "b1" << "r1" << "b1" << "r1" << "b1"
#    g << "r3" << "b2" << "r2" << "b2" << "r2" << "b2"
#    g << "r2" << "b3" << "r3" << "b3" << "r3" << "b3"
#    g << "r4" << "b4" << "r4" << "b4" << "r4" << "b4"
#    g << "r6" << "b5" << "r5" << "b5" << "r5" << "b5"
#    g << "r5" << "b6" << "r6" << "b6" << "r6"
#    assert( !g.final? )
#    g << "b6"
#    assert( g.final? )
#
#    assert( g.draw? )
#    assert( !g.winner?( Player.black ) )
#    assert( !g.loser?( Player.black ) )
#    assert( !g.winner?( Player.white ) )
#    assert( !g.loser?( Player.white ) )
#
#    assert_equal( 0, g.score( Player.black ) )
#    assert_equal( 0, g.score( Player.white ) )
#  end

#  def test_game05
#    # This game is going to be a win for Blue (horizontal 5-in-a-row)
#    g = Game.new( Othello )
#    g << "r6" << "b0" << "r0" << "b2" << "r2" << "b3" << "r3" << "b4" << "r4"
#    assert( !g.final? )
#    g << "b1"
#    assert( g.final? )
#
#    assert( !g.draw? )
#    assert( !g.winner?( Player.black ) )
#    assert( g.loser?( Player.black ) )
#    assert( g.winner?( Player.white ) )
#    assert( !g.loser?( Player.white ) )
#
#    assert_equal( -1, g.score( Player.black ) )
#    assert_equal( 1, g.score( Player.white ) )
#  end

end

