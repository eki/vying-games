
require "test/unit"
require "board/standard"

class TestPiece < Test::Unit::TestCase
  def test_initialize
    p = Piece.new( 'Black', 'b' )

    assert_equal( 'Black', p.name )
    assert_equal( 'b', p.short )

    assert_equal( 'Black', Piece.black.name )
    assert_equal( 'b', Piece.black.short )
  end

  def test_equal
    p = Piece.new( 'Black', 'b' )
    assert( p == p )
    assert( p == Piece.black )
    assert( p == Piece.blue )  # == only compare's short
    assert( p != Piece.red )
    assert( p != nil )
  end

  def test_to_s
    assert_equal( 'b', Piece.black.to_s )
    assert_equal( 'b', Piece.blue.to_s )
    assert_equal( 'r', Piece.red.to_s )
    assert_equal( '@', Piece.new( 'Black', '@' ).to_s )
  end
end

class TestCoord < Test::Unit::TestCase
  def test_initialize
    c = Coord[0,1]
    assert_equal( 0, c.x )
    assert_equal( 1, c.y )
    assert_equal( c, Coord.new( 0, 1 ) )
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

  def test_subtraction
    c00 = Coord[0,0]
    c10 = Coord[1,0]
    c01 = Coord[0,1]
    c11 = Coord[1,1]
    c21 = Coord[2,1]
    c42 = Coord[4,2]
    cminus42 = Coord[-4,-2]

    assert_equal( c00, c00 - c00 )
    assert_equal( c10, c10 - c00 )
    assert_equal( c00, c21 - c21 )
    assert_equal( c00, c10 - c10 )
    assert_equal( c10, c42 - c21 - c01 - c10 )
    assert_equal( cminus42, c00 - c42 )
  end

  def test_to_s
    #assert_equal( "(0,0)", Coord[0,0].to_s )
    #assert_equal( "(1,2)", Coord[1,2].to_s )
    assert_equal( "a0", Coord[0,0].to_s )
    assert_equal( "b2", Coord[1,2].to_s )
  end
end

class TestCoords < Test::Unit::TestCase
  def test_initialize
    coords = Coords.new( 3, 4 )
    assert_equal( 3, coords.width )
    assert_equal( 4, coords.height )
  end

  def test_each
    coords = Coords.new( 2, 3 )
    a = [Coord[0,0], Coord[1,0], Coord[0,1],
         Coord[1,1], Coord[0,2], Coord[1,2]]
    i = 0
    coords.each { |c| assert_equal( a[i], c ); i += 1 }
  end

  def test_include
    coords = Coords.new( 2, 3 )

    assert( coords.include?( Coord[0,0] ) )
    assert( coords.include?( Coord[1,0] ) )
    assert( coords.include?( Coord[0,2] ) )
    assert( coords.include?( Coord[1,2] ) )
    assert( coords.include?( Coord[1,1] ) )

    assert( ! coords.include?( Coord[-1,0] ) )
    assert( ! coords.include?( Coord[0,-1] ) )
    assert( ! coords.include?( Coord[-1,-1] ) )
    assert( ! coords.include?( Coord[2,0] ) )
    assert( ! coords.include?( Coord[0,3] ) )
    assert( ! coords.include?( Coord[2,3] ) )
    assert( ! coords.include?( Coord[100,100] ) )
  end

  def test_row
    coords = Coords.new( 2, 3 )

    assert_equal( 2, coords.row( Coord[0,0] ).length )
    assert_equal( 2, coords.row( Coord[0,1] ).length )
    assert_equal( 2, coords.row( Coord[0,2] ).length )

    assert_equal( [Coord[0,0], Coord[1,0]], coords.row( Coord[0,0] ) )
    assert_equal( [Coord[0,0], Coord[1,0]], coords.row( Coord[1,0] ) )

    assert_equal( [Coord[0,1], Coord[1,1]], coords.row( Coord[0,1] ) )
    assert_equal( [Coord[0,1], Coord[1,1]], coords.row( Coord[1,1] ) )

    assert_equal( [Coord[0,2], Coord[1,2]], coords.row( Coord[0,2] ) )
    assert_equal( [Coord[0,2], Coord[1,2]], coords.row( Coord[1,2] ) )
  end

  def test_column
    coords = Coords.new( 2, 3 )

    assert_equal( 3, coords.column( Coord[0,0] ).length )
    assert_equal( 3, coords.column( Coord[1,0] ).length )

    col1 = [Coord[0,0], Coord[0,1], Coord[0,2]]
    col2 = [Coord[1,0], Coord[1,1], Coord[1,2]]

    assert_equal( col1, coords.column( Coord[0,0] ) )
    assert_equal( col1, coords.column( Coord[0,1] ) )
    assert_equal( col1, coords.column( Coord[0,2] ) )

    assert_equal( col2, coords.column( Coord[1,0] ) )
    assert_equal( col2, coords.column( Coord[1,1] ) )
    assert_equal( col2, coords.column( Coord[1,2] ) )
  end

  def test_diagonal
    coords = Coords.new( 2, 3 )

    diag1p = [Coord[0,0], Coord[1,1]]
    diag2p = [Coord[1,0]]
    diag3p = [Coord[0,1], Coord[1,2]]
    diag4p = [Coord[0,2]]

    diag1n = [Coord[0,0]]
    diag2n = [Coord[1,0], Coord[0,1]]
    diag3n = [Coord[1,1], Coord[0,2]]
    diag4n = [Coord[1,2]]

    assert_equal( 2, coords.diagonal( Coord[0,0], 1 ).length )
    assert_equal( 1, coords.diagonal( Coord[1,0], 1 ).length )
    assert_equal( 2, coords.diagonal( Coord[0,1], 1 ).length )
    assert_equal( 1, coords.diagonal( Coord[0,2], 1 ).length )

    assert_equal( 1, coords.diagonal( Coord[0,0], -1 ).length )
    assert_equal( 2, coords.diagonal( Coord[1,0], -1 ).length )
    assert_equal( 2, coords.diagonal( Coord[1,1], -1 ).length )
    assert_equal( 1, coords.diagonal( Coord[1,2], -1 ).length )

    assert_equal( diag1p, coords.diagonal( Coord[0,0], 1 ) )
    assert_equal( diag1p, coords.diagonal( Coord[1,1], 1 ) )

    assert_equal( diag2p, coords.diagonal( Coord[1,0], 1 ) )

    assert_equal( diag3p, coords.diagonal( Coord[0,1], 1 ) )
    assert_equal( diag3p, coords.diagonal( Coord[1,2], 1 ) )

    assert_equal( diag4p, coords.diagonal( Coord[0,2], 1 ) )

    assert_equal( diag1p, coords.diagonal( Coord[0,0] ) )
    assert_equal( diag1p, coords.diagonal( Coord[1,1] ) )

    assert_equal( diag2p, coords.diagonal( Coord[1,0] ) )

    assert_equal( diag3p, coords.diagonal( Coord[0,1] ) )
    assert_equal( diag3p, coords.diagonal( Coord[1,2] ) )

    assert_equal( diag4p, coords.diagonal( Coord[0,2] ) )

    assert_equal( diag1n, coords.diagonal( Coord[0,0], -1 ) )

    assert_equal( diag2n, coords.diagonal( Coord[1,0], -1 ) )
    assert_equal( diag2n, coords.diagonal( Coord[0,1], -1 ) )

    assert_equal( diag3n, coords.diagonal( Coord[1,1], -1 ) )
    assert_equal( diag3n, coords.diagonal( Coord[0,2], -1 ) )

    assert_equal( diag4n, coords.diagonal( Coord[1,2], -1 ) )
  end

  def test_neighbors
    coords = Coords.new( 8, 8 )

    n00 = [Coord[0,1], Coord[1,0], Coord[1,1]]
    n70 = [Coord[6,0], Coord[7,1], Coord[6,1]]
    n07 = [Coord[0,6], Coord[1,7], Coord[1,6]]
    n77 = [Coord[7,6], Coord[6,7], Coord[6,6]]
    n30 = [Coord[2,0], Coord[4,0], Coord[2,1], Coord[3,1], Coord[4,1]]
    n03 = [Coord[0,2], Coord[0,4], Coord[1,2], Coord[1,3], Coord[1,4]]
    n37 = [Coord[2,7], Coord[4,7], Coord[2,6], Coord[3,6], Coord[4,6]]
    n73 = [Coord[7,2], Coord[7,4], Coord[6,2], Coord[6,3], Coord[6,4]]
    n33 = [Coord[2,3], Coord[4,3], Coord[3,2], Coord[3,4],
           Coord[2,2], Coord[4,4], Coord[2,4], Coord[4,2]]

    assert_equal( n00.sort, coords.neighbors( Coord[0,0] ).sort )
    assert_equal( n70.sort, coords.neighbors( Coord[7,0] ).sort )
    assert_equal( n07.sort, coords.neighbors( Coord[0,7] ).sort )
    assert_equal( n77.sort, coords.neighbors( Coord[7,7] ).sort )
    assert_equal( n30.sort, coords.neighbors( Coord[3,0] ).sort )
    assert_equal( n03.sort, coords.neighbors( Coord[0,3] ).sort )
    assert_equal( n37.sort, coords.neighbors( Coord[3,7] ).sort )
    assert_equal( n73.sort, coords.neighbors( Coord[7,3] ).sort )
    assert_equal( n33.sort, coords.neighbors( Coord[3,3] ).sort )

    assert_equal( [Coord[4,3]], coords.neighbors( Coord[4,4], [:n] ) )
    assert_equal( [Coord[4,5]], coords.neighbors( Coord[4,4], [:s] ) )
    assert_equal( [Coord[3,4]], coords.neighbors( Coord[4,4], [:w] ) )
    assert_equal( [Coord[5,4]], coords.neighbors( Coord[4,4], [:e] ) )
    assert_equal( [Coord[5,3]], coords.neighbors( Coord[4,4], [:ne] ) )
    assert_equal( [Coord[3,3]], coords.neighbors( Coord[4,4], [:nw] ) )
    assert_equal( [Coord[5,5]], coords.neighbors( Coord[4,4], [:se] ) )
    assert_equal( [Coord[3,5]], coords.neighbors( Coord[4,4], [:sw] ) )

    n44nssw = [Coord[4,3], Coord[4,5], Coord[3,5]]
 
    assert_equal( n44nssw, coords.neighbors( Coord[4,4], [:n,:s,:sw] ) )
  end

  def test_next
    coords = Coords.new( 8, 8 )

    assert_equal( Coord[0,1], coords.next( Coord[0,0], :s ) )
    assert_equal( Coord[1,0], coords.next( Coord[0,0], :e ) )
    assert_equal( nil,        coords.next( Coord[0,0], :n ) )
    assert_equal( nil,        coords.next( Coord[0,0], :w ) )

    assert_equal( Coord[7,1], coords.next( Coord[7,0], :s ) )
    assert_equal( nil,        coords.next( Coord[7,0], :e ) )
    assert_equal( nil,        coords.next( Coord[7,0], :n ) )
    assert_equal( Coord[6,0], coords.next( Coord[7,0], :w ) )

    assert_equal( nil,        coords.next( Coord[0,7], :s ) )
    assert_equal( Coord[1,7], coords.next( Coord[0,7], :e ) )
    assert_equal( Coord[0,6], coords.next( Coord[0,7], :n ) )
    assert_equal( nil,        coords.next( Coord[0,7], :w ) )

    assert_equal( nil,        coords.next( Coord[7,7], :s ) )
    assert_equal( nil,        coords.next( Coord[7,7], :e ) )
    assert_equal( Coord[7,6], coords.next( Coord[7,7], :n ) )
    assert_equal( Coord[6,7], coords.next( Coord[7,7], :w ) )
  end

  def test_line
    coords = Coords.new( 8, 8 )

    n44s = [Coord[4,5], Coord[4,6], Coord[4,7]]
    n44n = [Coord[4,3], Coord[4,2], Coord[4,1], Coord[4,0]]
    n44e = [Coord[5,4], Coord[6,4], Coord[7,4]]
    n44w = [Coord[3,4], Coord[2,4], Coord[1,4], Coord[0,4]]

    n44ne = [Coord[5,3], Coord[6,2], Coord[7,1]]
    n44nw = [Coord[3,3], Coord[2,2], Coord[1,1], Coord[0,0]]
    n44se = [Coord[5,5], Coord[6,6], Coord[7,7]]
    n44sw = [Coord[3,5], Coord[2,6], Coord[1,7]]

    assert_equal( n44s, coords.line( Coord[4,4], :s ) )
    assert_equal( n44n, coords.line( Coord[4,4], :n ) )
    assert_equal( n44e, coords.line( Coord[4,4], :e ) )
    assert_equal( n44w, coords.line( Coord[4,4], :w ) )

    assert_equal( n44ne, coords.line( Coord[4,4], :ne ) )
    assert_equal( n44nw, coords.line( Coord[4,4], :nw ) )
    assert_equal( n44se, coords.line( Coord[4,4], :se ) )
    assert_equal( n44sw, coords.line( Coord[4,4], :sw ) )

    assert_equal( nil, coords.line( Coord[0,0], :n ) )
    assert_equal( nil, coords.line( Coord[0,0], :w ) )
    assert_equal( nil, coords.line( Coord[0,0], :nw ) )

    assert_equal( nil, coords.line( Coord[7,0], :n ) )
    assert_equal( nil, coords.line( Coord[7,0], :e ) )
    assert_equal( nil, coords.line( Coord[7,0], :ne ) )

    assert_equal( nil, coords.line( Coord[0,7], :s ) )
    assert_equal( nil, coords.line( Coord[0,7], :w ) )
    assert_equal( nil, coords.line( Coord[0,7], :sw ) )

    assert_equal( nil, coords.line( Coord[7,7], :s ) )
    assert_equal( nil, coords.line( Coord[7,7], :e ) )
    assert_equal( nil, coords.line( Coord[7,7], :se ) )
  end

  def test_to_s
    coords = Coords.new( 2, 2 )
    #assert_equal( "(0,0)(1,0)(0,1)(1,1)", coords.to_s )
    assert_equal( "a0b0a1b1", coords.to_s )
  end
end

class TestBoard < Test::Unit::TestCase
  def test_initialize
    b = Board.new( 3, 3 )
    assert_equal( Coords.new( 3, 3 ), b.coords )
    assert_equal( nil, b[0,0] ) 
  end

  def test_dup
    b = Board.new( 3, 3 )

    b[1,1] = :orig
    b2 = b.dup

    assert_equal( :orig, b[1,1] )
    assert_equal( :orig, b2[1,1] )

    b2[1,1] = :test

    assert_equal( :orig, b[1,1] )
    assert_equal( :test, b2[1,1] )
  end

  def test_equal
    b = Board.new( 3, 3 )
    assert( b == b )

    b2 = b.dup
    assert( b == b2 )
    assert( b2 == b )

    assert( b == Board.new( 3, 3 ) )

    b2[0,0] = Piece.x
    assert( b != b2 )

    assert( b != Board.new( 4, 4 ) )
  end

  def test_assignment
    b = Board.new( 3, 3 )

    b[0,0] = :zero
    b[Coord.new(1,0)] = :one
    b[Coord[2,0]] = :two

    assert_equal( :zero, b[0,0] )
    assert_equal( :zero, b[Coord[0,0]] )
    assert_equal( [:zero,:two], b[[Coord[0,0], Coord[2,0]]] )
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
    b[3,3] = Piece.x
    b[3,4] = Piece.x
    b[3,6] = Piece.x
    b[2,2] = Piece.o
    b[1,1] = Piece.o
    b[0,0] = Piece.o

    count1 = b.each_from( Coord[3,3], [:nw,:s] ) { |p| !p.nil? }
    count2 = b.each_from( Coord[3,3], [:nw,:s] ) { |p| p == Piece.x }
    count3 = b.each_from( Coord[3,3], [:nw] ) { |p| p == Piece.x }
    count4 = b.each_from( Coord[3,3], [:nw,:s] ) { |p| p == Piece.o }
    count5 = b.each_from( Coord[3,6], [:nw,:s,:e,:w] ) { |p| !p.nil? }

    assert_equal( 4, count1 )
    assert_equal( 1, count2 )
    assert_equal( 0, count3 )
    assert_equal( 3, count4 )
    assert_equal( 0, count5 )
  end

  def test_count
    b = Board.new( 3, 3 )

    assert_equal( 9, b.count( nil ) )

    b[0,0] = :b00
    b[1,1] = :b11

    assert_equal( 7, b.count( nil ) )
    assert_equal( 1, b.count( :b00 ) )
    assert_equal( 1, b.count( :b11 ) )
    assert_equal( 0, b.count( :b22 ) )

    b[2,2] = :b22

    assert_equal( 1, b.count( :b22 ) )

    b[1,0] = b[1,1] = Piece.x

    assert_equal( 2, b.count( Piece.x ) )
    assert_equal( 0, b.count( :b11 ) )
  end

  def test_to_s
    b = Board.new( 2, 2 )
    b[0,0] = '0'
    b[1,0] = '1'
    b[0,1] = '2'
    b[1,1] = '3'
   
    assert_equal( "01\n23\n", b.to_s )
    assert_equal( "01", b.to_s( b.coords.row( Coord[0,0] ) ) )
    assert_equal( "02", b.to_s( b.coords.column( Coord[0,0] ) ) )
    assert_equal( "03", b.to_s( b.coords.diagonal( Coord[0,0], 1 ) ) )
  end
end

