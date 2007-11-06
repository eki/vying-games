require 'test/unit'

require 'vying/board/board'

class TestBoard < Test::Unit::TestCase

  def test_initialize
    b = Board.new( 7, 6 )
    assert_equal( 7, b.width )
    assert_equal( 6, b.height )

    b = Board.new( 7 )
    assert_equal( 7, b.width )
    assert_equal( 8, b.height )

    b = Board.new
    assert_equal( 8, b.width )
    assert_equal( 8, b.height )

  end

  def test_bad_subscripts
    b = Board.new( 7, 6 )
    assert_equal( nil, b[-1,0] )
    assert_equal( nil, b[0,-1] )
    assert_equal( nil, b[-1,-1] )
    assert_equal( nil, b[7,0] )
    assert_equal( nil, b[7,6] )
    assert_equal( nil, b[0,6] )
    assert_equal( :black, b[0,6] = :black )
    assert_equal( nil, b[0,6] )
    assert_equal( nil, b[nil] )
  end

  def test_ci
    b = Board.new( 7, 6 )
    assert_equal( 0, b.ci( 0, 0 ) )
    assert_equal( 2, b.ci( 2, 0 ) )
    assert_equal( 14, b.ci( 0, 2 ) )
    assert_equal( 17, b.ci( 3, 2 ) )
  end

  def test_dup
    b = Board.new( 7, 6 )

    assert_equal( :black, b[3,4] = :black )
    b2 = b.dup

    assert_equal( :black, b2[3,4] )
    assert_equal( :white, b2[0,0] = :white )
    assert_equal( nil, b[0,0] )
    assert_equal( :black, b[1,1] = :black )
    assert_equal( nil, b2[1,1] )
    assert_not_equal( b, b2 )

    assert_equal( :black, b2[1,1] = :black )
    assert_equal( :white, b[0,0] = :white )
    assert_equal( b, b2 )

    assert_equal( :blue, b[0,0] = :blue )
    assert_equal( :red, b[0,1] = :red   )

    assert_equal( :red, b2[0,0] = :red   )
    assert_equal( :blue, b2[0,1] = :blue )

    assert_equal( nil, b2[0,0] = nil )
    assert_equal( nil, b2[0,1] = nil )

    assert_not_equal( b, b2 )  # Are they sharing key?
  end

  def test_assignment
    b = Board.new( 7, 6 )
    assert_equal( nil, b[3,4] )
    assert_equal( :black, b[3,4] = :black )
    assert_equal( :black, b[3,4] )

    assert_equal( nil, b[:a1] )
    assert_equal( :white, b[:a1] = :white )
    assert_equal( :white, b[:a1] )

    assert_equal( nil, b[Coord[2,2]] )
    assert_equal( :white, b[Coord[2,2]] = :white )
    assert_equal( :white, b[Coord[2,2]] )

    assert_equal( [:black,:white,nil,:white], b[[3,4],:a1,:b2,Coord[2,2]] )
  end

  def test_in_bounds
    b = Board.new( 7, 6 )
    assert( b.in_bounds?( 0, 0 ) )
    assert( b.in_bounds?( 6, 0 ) )
    assert( b.in_bounds?( 0, 5 ) )
    assert( b.in_bounds?( 6, 5 ) )

    assert_nil( b.in_bounds?( -1, 0 ) )
    assert_nil( b.in_bounds?( 0, -1 ) )
    assert_nil( b.in_bounds?( 7, 0 ) )
    assert_nil( b.in_bounds?( 0, 6 ) )
  end

  def test_equals
    b1 = Board.new( 7, 6 )
    b2 = Board.new( 7, 6 )
    b3 = Board.new( 6, 7 )
    b4 = Board.new( 1, 2 )

    assert_equal( b1, b2 )

    assert_not_equal( b1, b3 )
    assert_not_equal( b1, b4 )

    assert_equal( b1, b1.dup )

    assert_equal( :white, b2[3,3] = :white )
    assert_not_equal( b1, b2 )

    assert_equal( :white, b1[3,3] = :white )
    assert_equal( b1, b2 )

    assert_equal( :blue, b1[3,4] = :blue )   # :blue added to key
    assert_equal( :red,  b2[3,4] = :red  )   # :red  added to key

    assert_not_equal( b1, b2 )
  end

  def test_hash
    b1 = Board.new( 7, 6 )
    
    assert_equal( :black, b1[:a1,:a2,:b4,:e3] = :black )

    b2 = b1.dup

    assert_equal( b1, b2 )
    assert_equal( b1.hash, b2.hash )
  end

  def test_count
    b = Board.new( 3, 4 )

    assert_equal( 0, b.count( :black ) )
    assert_equal( :black, b[:a1,:a2,:a3,:a4] = :black )
    assert_equal( 4, b.count( :black ) )

    assert_equal( 0, b.count( :white ) )
    assert_equal( :white, b[:b1,:b2,:b3,:b4,:c1,:c2,:c3,:c4] = :white )
    assert_equal( 8, b.count( :white ) )

    assert_equal( 0, b.count( :blue ) )
    assert_equal( :blue, b[:a2,:b3] = :blue )
    assert_equal( 2, b.count( :blue  ) )
    assert_equal( 3, b.count( :black ) )
    assert_equal( 7, b.count( :white ) )
  end

  def test_occupied
    b = Board.new( 4, 4 )
    assert_equal( nil, b.occupied[:black] )
    b[1,1] = :black
    assert_equal( [Coord[1,1]], b.occupied[:black] )
    assert_equal( nil, b.occupied[:white] )
    b[1,1] = :white
    assert_equal( [], b.occupied[:black] )
    assert_equal( [Coord[1,1]], b.occupied[:white] )
  end

  def test_each
    b = Board.new( 2, 2 )
    b[0,0] = :b00
    b[1,0] = :b10
    b[0,1] = :b01
    b[1,1] = :b11

    a = [:b00, :b10, :b01, :b11]
    i = 0

    b.each { |p| assert_equal( a[i], p ); i += 1 }
  end

  def test_each_from
    b = Board.new( 8, 8 )
    b[3,3] = :x
    b[3,4] = :x
    b[3,6] = :x
    b[2,2] = :o
    b[1,1] = :o
    b[0,0] = :o

    count1 = b.each_from( Coord[3,3], [:nw,:s] ) { |p| !p.nil? }
    count2 = b.each_from( Coord[3,3], [:nw,:s] ) { |p| p == :x }
    count3 = b.each_from( Coord[3,3], [:nw] ) { |p| p == :x }
    count4 = b.each_from( Coord[3,3], [:nw,:s] ) { |p| p == :o }
    count5 = b.each_from( Coord[3,6], [:nw,:s,:e,:w] ) { |p| !p.nil? }

    assert_equal( 4, count1 )
    assert_equal( 1, count2 )
    assert_equal( 0, count3 )
    assert_equal( 3, count4 )
    assert_equal( 0, count5 )
  end

  def test_row
    b = Board.new( 3, 2 )

    assert_equal( [nil,nil,nil], b.row(0) )
    assert_equal( :black, b[:a1,:b1] = :black )
    assert_equal( [:black,:black,nil], b.row(0) )
  end

  def test_move
    b = Board.new( 3, 3 )

    assert_equal( :x, b[0,0] = :x )
    assert_equal( :o, b[2,2] = :o )
    assert_equal( nil, b[1,1] )

    assert_equal( b, b.move( [0,0], [1,1] ) )

    assert_equal( nil, b[0,0] )
    assert_equal( :o, b[2,2] )
    assert_equal( :x, b[1,1] )

    assert_equal( b, b.move( [2,2], [1,1] ) )

    assert_equal( nil, b[0,0] )
    assert_equal( nil, b[2,2] )
    assert_equal( :o, b[1,1] )
  end

  def test_clear
    b = Board.new( 4, 4 )
    assert_equal( 16, b.empty_count )
    assert_equal( :black, b[:a1,:a2,:a3] = :black )
    assert_equal( :white, b[:b1,:b2,:b3,:b4] = :white )
    assert_equal( 9, b.empty_count )
    assert_equal( 16, b.clear.empty_count )
  end

  def test_to_s
    b = Board.new( 2, 2 )
    b[0,0] = '0'
    b[1,0] = '1'
    b[0,1] = '2'
    b[1,1] = '3'
  
    assert_equal( " ab \n1011\n2232\n ab \n", b.to_s )

    b = Board.new( 2, 10 )
    b[0,0], b[1,0], b[0,9], b[1,9] = 'a', 'b', 'c', 'd'
    s = <<EOF
  ab  
 1ab1 
 2  2 
 3  3 
 4  4 
 5  5 
 6  6 
 7  7 
 8  8 
 9  9 
10cd10
  ab  
EOF

    assert_equal( s, b.to_s )
  end

end

