
require "test/unit"
require "game"
require "rules/test_rules"

class TestOthelloBoard < Test::Unit::TestCase
  def test_valid_ns
    b = OthelloBoard.new( 8, 8 )

    b[3,3] = :black
    b[3,4] = :white

    assert( b.valid?( Coord[3,5], :black ) )
    assert( b.valid?( Coord[3,5], :black, [:n] ) )
    assert( !b.valid?( Coord[3,5], :white, [:n] ) )

    assert( b.valid?( Coord[3,2], :white ) ) 
    assert( b.valid?( Coord[3,2], :white, [:s] ) ) 
    assert( !b.valid?( Coord[3,2], :black, [:s] ) ) 
  end

  def test_valid_ew
    b = OthelloBoard.new( 8, 8 )

    b[3,3] = :black
    b[4,3] = :white

    assert( b.valid?( Coord[5,3], :black ) )
    assert( b.valid?( Coord[5,3], :black, [:w] ) )
    assert( !b.valid?( Coord[5,3], :white, [:w] ) )

    assert( b.valid?( Coord[2,3], :white ) )
    assert( b.valid?( Coord[2,3], :white, [:e] ) )
    assert( !b.valid?( Coord[2,3], :black, [:e] ) )

    # check flip 2 in same direction

    b[5,3] = :white

    assert( b.valid?( Coord[6,3], :black ) )
    assert( b.valid?( Coord[6,3], :black, [:w] ) )

    assert( !b.valid?( Coord[6,3], :white, [:w] ) )
  end

  def test_valid_nw_se
    b = OthelloBoard.new( 8, 8 )

    b[0,0] = :white
    b[1,1] = :black
    b[3,3] = :black
    b[4,4] = :white

    assert( b.valid?( Coord[2,2], :white ) )
    assert( b.valid?( Coord[2,2], :white, [:nw] ) )
    assert( b.valid?( Coord[2,2], :white, [:se] ) )
    assert( b.valid?( Coord[2,2], :white, [:nw,:se] ) )
    assert( b.valid?( Coord[2,2], :white, [:se,:nw] ) )

    assert( !b.valid?( Coord[2,2], :black, [:se,:nw] ) )
  end

  def test_valid_ne_sw
    b = OthelloBoard.new( 8, 8 )

    b[7,0] = :black
    b[6,1] = :white
    b[5,2] = :white
    b[3,4] = :white
    b[2,5] = :black

    assert( b.valid?( Coord[4,3], :black ) )
    assert( b.valid?( Coord[4,3], :black, [:ne] ) )
    assert( b.valid?( Coord[4,3], :black, [:sw] ) )
    assert( b.valid?( Coord[4,3], :black, [:ne,:sw] ) )
    assert( b.valid?( Coord[4,3], :black, [:sw,:ne] ) )

    assert( !b.valid?( Coord[4,3], :white, [:sw,:ne] ) )
  end

  def test_valid_empty
    b = OthelloBoard.new( 8, 8 )

    b[3,3] = :black
    b[5,5] = :white

    b.coords.each do |c| 
      assert( !b.valid?( c, :black ) )
      assert( !b.valid?( c, :white ) )
    end
  end

  def test_valid_edges
    b = OthelloBoard.new( 8, 8 )

    b[0,0] = b[3,0] = b[3,1] = b[7,0] = b[7,3] = :black
    b[7,7] = b[3,7] = b[3,6] = b[0,7] = b[0,3] = :white

    b.coords.each do |c| 
      assert( !b.valid?( c, :black ) )
      assert( !b.valid?( c, :white ) )
    end
  end

  def test_place_n
    b = OthelloBoard.new( 8, 8 )

    b[3,3] = :black
    b[3,4] = :white

    b.place( Coord[3,5], :black )

    assert_equal( b[3,3], :black )
    assert_equal( b[3,4], :black )
    assert_equal( b[3,5], :black )

    assert_equal( 8*8-3, b.count( nil ) )
  end

  def test_place_s
    b = OthelloBoard.new( 8, 8 )

    b[3,3] = :black
    b[3,4] = :white

    b.place( Coord[3,2], :white )

    assert_equal( b[3,2], :white )
    assert_equal( b[3,3], :white )
    assert_equal( b[3,4], :white )

    assert_equal( 8*8-3, b.count( nil ) )
  end

  def test_place_e
    b = OthelloBoard.new( 8, 8 )

    b[1,3] = :black
    b[2,3] = :black
    b[3,3] = :black
    b[4,3] = :white
    b[5,3] = :white

    b.place( Coord[0,3], :white )

    assert_equal( b[0,3], :white )
    assert_equal( b[1,3], :white )
    assert_equal( b[2,3], :white )
    assert_equal( b[3,3], :white )
    assert_equal( b[4,3], :white )
    assert_equal( b[5,3], :white )

    assert_equal( 8*8-6, b.count( nil ) )
  end

  def test_place_w
    b = OthelloBoard.new( 8, 8 )

    b[3,3] = :black
    b[4,3] = :white
    b[5,3] = :white

    b.place( Coord[6,3], :black )

    assert_equal( b[6,3], :black )
    assert_equal( b[3,3], :black )
    assert_equal( b[4,3], :black )
    assert_equal( b[5,3], :black )

    assert_equal( 8*8-4, b.count( nil ) )
  end

  def test_place_nw_se
    b = OthelloBoard.new( 8, 8 )

    b[0,0] = :black
    b[1,1] = :white
    b[2,2] = :white
    b[4,4] = :white
    b[5,5] = :black

    b.place( Coord[3,3], :black )

    assert_equal( b[0,0], :black )
    assert_equal( b[1,1], :black )
    assert_equal( b[2,2], :black )
    assert_equal( b[3,3], :black )
    assert_equal( b[4,4], :black )
    assert_equal( b[5,5], :black )

    assert_equal( 8*8-6, b.count( nil ) )
  end

  def test_place_ne_sw
    b = OthelloBoard.new( 8, 8 )

    b[7,0] = :black
    b[6,1] = :white
    b[5,2] = :white
    b[3,4] = :white
    b[2,5] = :black

    b.place( Coord[4,3], :black )

    assert_equal( b[7,0], :black )
    assert_equal( b[6,1], :black )
    assert_equal( b[5,2], :black )
    assert_equal( b[4,3], :black )
    assert_equal( b[3,4], :black )
    assert_equal( b[2,5], :black )

    assert_equal( 8*8-6, b.count( nil ) )
  end
end

class TestOthello < Test::Unit::TestCase
  include RulesTests

  def rules
    Othello
  end

  def test_initialize
    g = Game.new( Othello )

    b = OthelloBoard.new( 8, 8 )
    b[3,3] = b[4,4] = :white
    b[3,4] = b[4,3] = :black

    assert_equal( b, g.board )
    assert_equal( :black, g.turn.now )
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
    assert_equal( [:black,:white], g.players )
    assert_equal( [:black,:white], g.players )
  end

end

