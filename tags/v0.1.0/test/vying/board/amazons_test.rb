require 'test/unit'

require 'vying/board/amazons'

class TestAmazonsBoard < Test::Unit::TestCase

  def test_initialize
    b = AmazonsBoard.new
    assert_equal( 10, b.width )
    assert_equal( 10, b.height )

    assert_equal( :white, b[0,3] )
    assert_equal( :white, b[3,0] )
    assert_equal( :white, b[6,0] )
    assert_equal( :white, b[9,3] )

    assert_equal( :black, b[0,6] )
    assert_equal( :black, b[6,9] )
    assert_equal( :black, b[3,9] )
    assert_equal( :black, b[9,6] )
  end

  def test_territory_splits
    b = AmazonsBoard.new

    a4 = Coord[:a4]
    d1 = Coord[:d1]
    g1 = Coord[:g1]
    j4 = Coord[:j4]

    a7  = Coord[:a7]
    d10 = Coord[:d10]
    g10 = Coord[:g10]
    j7  = Coord[:j7]

    assert_equal( 1, b.territories.length )
    assert_equal( [a4, d1, g1, j4].sort, b.territories.first.white.sort )
    assert_equal( [a7, d10, g10, j7].sort, b.territories.first.black.sort )

    b[:f1,:f2,:f3,:f4,:f5,:f6,:f7,:f8,:f9,:f10] = :arrow

    b.update_territories

    assert_equal( 2, b.territories.length )
    assert_equal( [a4, d1].sort, b.territories.first.white.sort )
    assert_equal( [a7, d10].sort, b.territories.first.black.sort )
    assert_equal( [g1, j4].sort, b.territories.last.white.sort )
    assert_equal( [g10, j7].sort, b.territories.last.black.sort )

    b[:a2,:b2,:c2,:d2,:e2,:f2,:g2,:h2,:i2,:j2] = :arrow

    b.update_territories

    assert_equal( 4, b.territories.length )

    assert_equal( [a4], b.territories[0].white )
    assert_equal( [a7, d10].sort, b.territories[0].black.sort )
    
    assert_equal( [d1], b.territories[1].white )
    assert_equal( [], b.territories[1].black )

    assert_equal( [g1], b.territories[2].white )
    assert_equal( [], b.territories[2].black )

    assert_equal( [j4], b.territories[3].white )
    assert_equal( [g10, j7].sort, b.territories[3].black.sort )

    a1 = Coord[:a1]
    b1 = Coord[:b1]
    c1 = Coord[:c1]
    e1 = Coord[:e1]

    assert_equal( [d1,e1,c1,b1,a1].sort, b.territories[1].coords.sort )

  end

end

