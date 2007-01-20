require 'test/unit'

require 'vying'

class TestOthelloBoard < Test::Unit::TestCase
  def test_initialize
    b = OthelloBoard.new
    assert_equal( 8, b.width )
    assert_equal( 8, b.height )
    assert_equal( :black, b[3,4] )
    assert_equal( :black, b[4,3] )
    assert_equal( :white, b[3,3] )
    assert_equal( :white, b[4,4] )
  end

  def test_dup
    b = OthelloBoard.new
    b2 = b.dup

    assert_equal( b, b2 )
    assert_equal( b[3,3], b2[3,3] )
    assert_equal( b[0,0], b2[0,0] )
    assert_equal( b.frontier, b2.frontier )
    assert_equal( b.occupied, b2.occupied )

    b2.place( Coord[3,2], :black )

    assert_not_equal( b, b2 )
    assert_not_equal( b[3,3], b2[3,3] )
    assert_not_equal( b[3,2], b2[3,2] )
    assert_not_equal( b.frontier, b2.frontier )
    assert_not_equal( b.occupied, b2.occupied )
  end

  def test_valid_ns
    b = OthelloBoard.new.clear

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
    b = OthelloBoard.new.clear

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
    b = OthelloBoard.new.clear

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
    b = OthelloBoard.new.clear

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
    b = OthelloBoard.new.clear

    b[3,3] = :black
    b[5,5] = :white

    b.coords.each do |c| 
      assert( !b.valid?( c, :black ) )
      assert( !b.valid?( c, :white ) )
    end
  end

  def test_valid_edges
    b = OthelloBoard.new.clear

    b[0,0] = b[3,0] = b[3,1] = b[7,0] = b[7,3] = :black
    b[7,7] = b[3,7] = b[3,6] = b[0,7] = b[0,3] = :white

    b.coords.each do |c| 
      assert( !b.valid?( c, :black ), "#{c}, :black" )
      assert( !b.valid?( c, :white ), "#{c}, :white" )
    end
  end

  def test_place_n
    b = OthelloBoard.new.clear

    b[3,3] = :black
    b[3,4] = :white

    b.place( Coord[3,5], :black )

    assert_equal( b[3,3], :black )
    assert_equal( b[3,4], :black )
    assert_equal( b[3,5], :black )

    assert_equal( 8*8-3, b.count( nil ) )
  end

  def test_place_s
    b = OthelloBoard.new.clear

    b[3,3] = :black
    b[3,4] = :white

    b.place( Coord[3,2], :white )

    assert_equal( b[3,2], :white )
    assert_equal( b[3,3], :white )
    assert_equal( b[3,4], :white )

    assert_equal( 8*8-3, b.count( nil ) )
  end

  def test_place_e
    b = OthelloBoard.new.clear

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
    b = OthelloBoard.new.clear

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
    b = OthelloBoard.new.clear

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
    b = OthelloBoard.new.clear

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

  def test_occupied
    b = OthelloBoard.new
    o = [Coord[3,3], Coord[3,4], Coord[4,3], Coord[4,4]]

    assert_equal( o.sort, b.occupied.sort )

    b.place( Coord[3,2], :black )
    assert_equal( (o + [Coord[3,2]]).sort, b.occupied.sort )

    # Commented out because only #place actually updates occupied
#   b.clear
#   b[0,0] = :black
#   assert_equal( [Coord[0,0]], b.occupied )   
  end

  def test_frontier
    b = OthelloBoard.new
    f = [Coord[2,2], Coord[3,2], Coord[4,2], Coord[5,2],
         Coord[5,3], Coord[5,4], Coord[5,5],
         Coord[4,5], Coord[3,5], Coord[2,5],
         Coord[2,4], Coord[2,3]]

    assert_equal( f.sort, b.frontier.sort )

    b.place( Coord[3,2], :black )
    f -= [Coord[3,2]]
    f += [Coord[2,1],Coord[3,1],Coord[4,1]]
    assert_equal( f.sort, b.frontier.sort )

    # Commented out because only #place actually updated frontier
#   b.clear
#   b[0,0] = :black
#   f = [Coord[1,0],Coord[0,1],Coord[1,1]]
#   assert_equal( f.sort, b.frontier.sort )
  end
end

