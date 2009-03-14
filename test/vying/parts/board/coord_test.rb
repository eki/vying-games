
require 'test/unit'
require 'vying'

class TestCoord < Test::Unit::TestCase
  include Vying

  def test_initialize
    c = Coord[0,1]
    assert_equal( 0, c.x )
    assert_equal( 1, c.y )
    assert_equal( c, Coord.new( 0, 1 ) )

    c = Coord[:a2]
    assert_equal( 0, c.x )
    assert_equal( 1, c.y )
    assert_equal( c, Coord.new( 0, 1 ) )

    c = Coord["a2"]
    assert_equal( 0, c.x )
    assert_equal( 1, c.y )
    assert_equal( c, Coord.new( 0, 1 ) )

    c = Coord["(0,1)"]
    assert_equal( 0, c.x )
    assert_equal( 1, c.y )
    assert_equal( c, Coord.new( 0, 1 ) )

    c = Coord["(-10,7)"]
    assert_equal( -10, c.x )
    assert_equal(   7, c.y )
    assert_equal( c, Coord.new( -10, 7 ) )

    c = Coord["(-10,-7)"]
    assert_equal( -10, c.x )
    assert_equal(  -7, c.y )
    assert_equal( c, Coord.new( -10, -7 ) )

    c = Coord["(11,-70)"]
    assert_equal(  11, c.x )
    assert_equal( -70, c.y )
    assert_equal( c, Coord.new( 11, -70 ) )

    cs = Coord[:a2, [0,0], 'c3', '(-1,-2)']
    assert_equal( Coord.new( 0, 1 ), cs[0] )
    assert_equal( Coord.new( 0, 0 ), cs[1] )
    assert_equal( Coord.new( 2, 2 ), cs[2] )
    assert_equal( Coord.new( -1, -2 ), cs[3] )

    assert_equal( nil, Coord[:h11o4] )
    assert_equal( nil, Coord["blah blah"] )
    assert_equal( nil, Coord[[1,2,3]] )
    assert_equal( nil, Coord[[:a, 2]] )

    cs = Coord[:a2, :h11o4, "blah", [0,0], 'c3']
    assert_equal( Coord.new( 0, 1 ), cs[0] )
    assert_equal( nil, cs[1] )
    assert_equal( nil, cs[2] )
    assert_equal( Coord.new( 0, 0 ), cs[3] )
    assert_equal( Coord.new( 2, 2 ), cs[4] )
  end

  def test_equal
    c1 = Coord[0,0]
    c2 = Coord[0,0]
    c3 = Coord[1,0]
    c4 = Coord[0,1]

    assert_equal( c1, c2 )
    assert_not_equal( c2, c3 )
    assert_not_equal( c1, c4 )
    assert_not_equal( c3, c4 )

    assert( c1 == c2 )
    assert( c1.eql?( c2 ) )
    assert( c3 != c4 )
  end

  def test_hash
    assert_equal( Coord[0,0], Coord[0,0] )
    assert_not_equal( Coord[0,0], Coord[0,1] )
  end

  def test_comparison
    unordered = [Coord[0,0],
                 Coord[-1,0],
                 Coord[-1,-1],
                 Coord[1,0],
                 Coord[0,-1],
                 Coord[1,1]]
    ordered = [Coord[-1,-1],
               Coord[0,-1],
               Coord[-1,0],
               Coord[0,0],
               Coord[1,0],
               Coord[1,1]]
    assert_equal( ordered, unordered.sort )
  end

  def test_addition
    c00 = Coord[0,0]
    c10 = Coord[1,0]
    c01 = Coord[0,1]
    c11 = Coord[1,1]
    c21 = Coord[2,1]
    c42 = Coord[4,2]

    assert_equal( c00, c00 + c00 )
    assert_equal( c10, c00 + c10 )
    assert_equal( c10, c10 + c00 )
    assert_equal( c11, c10 + c01 )
    assert_equal( c21, (c10 + c01) + c10 )
    assert_equal( c21, c10 + (c01 + c10) )
    assert_equal( c42, c21 + c21 )
  end

  def test_direction_to
    c = Coord[3,3]

    assert_equal( :n, c.direction_to( Coord[3,0] ) )
    assert_equal( :s, c.direction_to( Coord[3,5] ) )
    assert_equal( :e, c.direction_to( Coord[6,3] ) )
    assert_equal( :w, c.direction_to( Coord[2,3] ) )

    assert_equal( :ne, c.direction_to( Coord[5,1] ) )
    assert_equal( :nw, c.direction_to( Coord[2,2] ) )
    assert_equal( :se, c.direction_to( Coord[5,5] ) )
    assert_equal( :sw, c.direction_to( Coord[0,6] ) )

    assert_equal( nil, c.direction_to( Coord[4,1] ) )
    assert_equal( nil, c.direction_to( Coord[2,1] ) )
    assert_equal( nil, c.direction_to( Coord[5,6] ) )
    assert_equal( nil, c.direction_to( Coord[1,6] ) )
  end

  def test_next
    c = Coord[3,3]

    assert_equal( Coord[3,2], c.next( :n ) )
    assert_equal( Coord[3,4], c.next( :s ) )
    assert_equal( Coord[4,3], c.next( :e ) )
    assert_equal( Coord[2,3], c.next( :w ) )

    assert_equal( Coord[4,2], c.next( :ne ) )
    assert_equal( Coord[2,2], c.next( :nw ) )
    assert_equal( Coord[4,4], c.next( :se ) )
    assert_equal( Coord[2,4], c.next( :sw ) )

    assert_equal( nil, c.next( :blah ) )
  end

  def test_to_s
    assert_equal( 'a1', Coord[0,0].to_s )
    assert_equal( 'b3', Coord[1,2].to_s )
    assert_equal( 'a1', Coord[0,0].inspect )
  end

  def test_from_s
    assert_equal( Coord[0,0], Coord['a1'] )
    assert_equal( Coord[1,2], Coord[:b3] )
  end

  def test_to_coords
    assert_equal( [Coord[:a1],Coord[:j12],Coord[:b2]], "a1j12b2".to_coords )
    assert_equal( [Coord[:a1],Coord[:j12],Coord[:b2]], :a1j12b2.to_coords )
    assert_equal( [Coord[:a1]], Coord[:a1].to_coords )
    assert_equal( [Coord[:a1]], :a1.to_coords )
    assert_equal( [Coord[:a1]], "a1".to_coords )
    assert_equal( [Coord[:a1], Coord[-10,-10], Coord[:b3], Coord[:d3],
                  Coord[:a1]], "a1(-10,-10)(1,2)d3(0,0)".to_coords )
  end

  def test_to_sym
    assert_equal( :a1, Coord[0,0].to_sym )
    assert_equal( :j12, Coord[:j12].to_sym )
  end

  def test_dup
    c = Coord[:k9]
    assert_equal( c, c.dup )
    assert_equal( c.object_id, c.dup.object_id )
  end

  def test_marshal
    c = Coord[:j12]
    assert_equal( c, Marshal.load( Marshal.dump( c ) ) )
    assert_equal( c.object_id, Marshal.load( Marshal.dump( c ) ).object_id )
  end
end

