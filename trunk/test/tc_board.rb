
require "test/unit"
require "board"

class TestPiece < Test::Unit::TestCase
  def test_initialize
    red = Piece.new( 'Red', 'r' )
    assert_equal( 'Red', red.name )
    assert_equal( 'r', red.short )

    blue = Piece.new( 'Blue', 'b' )
    assert_equal( 'Blue', blue.name )
    assert_equal( 'b', blue.short )
  end

  def test_equal
    red = Piece.new( 'Red', 'r' )
    blue = Piece.new( 'Blue', 'b' )

    assert_equal( Piece.new( 'Red', 'r' ), red )
    assert_equal( red.dup, red )
    assert_not_equal( red, blue )

    assert( red == Piece.new( 'Red', 'r' ) )
    assert( red.eql?( Piece.new( 'Red', 'r' ) ) )
    assert( red != blue )
  end

  def test_hash
    assert_equal( Piece.new( 'Red', 'r' ).hash, Piece.red.hash )
    assert_not_equal( Piece.red.hash, Piece.blue.hash )
  end

  def test_become
    red = Piece.new( 'Red', 'r' )
    blue = Piece.new( 'Blue', 'b' )

    assert_not_equal( red, blue )

    blue.become( red )
    assert_equal( blue, red )
  end

  def test_to_s
    assert_equal( "Red (r)", Piece.red.to_s  )
    assert_equal( "X (x)", Piece.x.to_s )
    assert_equal( "Queen (q)", Piece.queen.to_s )
  end

  def test_method_missing
    red = Piece.new( 'Red', 'r' )
    blue = Piece.new( 'Blue', 'b' )

    assert_equal( red, Piece.red )
    assert_equal( blue, Piece.blue )
    assert_equal( Piece::EMPTY, Piece.empty )
  end
end

class TestTwoSidedPiece < Test::Unit::TestCase
  def test_initialize
    p2 = TwoSidedPiece.new( Piece.white, Piece.black )
    assert_equal( Piece.white, p2 )
    assert_equal( Piece.white.name, p2.name )
    assert_equal( Piece.white.short, p2.short )
    assert_equal( Piece.white, p2.up )
    assert_equal( Piece.black, p2.down )
  end

  def test_flip
    p2 = TwoSidedPiece.new( Piece.white, Piece.black )
    assert_equal( Piece.black, p2.flip! )
    assert_equal( Piece.black, p2.up )
    assert_equal( Piece.white, p2.down )
    assert_equal( Piece.white, p2.flip! )
    assert_equal( Piece.white, p2.up )
    assert_equal( Piece.black, p2.down )
  end

  def test_become
    p2 = TwoSidedPiece.new( Piece.white, Piece.black )
    assert_equal( Piece.white, p2.become( Piece.white ) )
    assert_equal( Piece.black, p2.become( Piece.black ) )
    assert_equal( Piece.black, p2.up )
    assert_equal( Piece.white, p2.down )
    assert_equal( Piece.empty, p2.become( Piece.empty ) )
    assert_equal( Piece.empty, p2.up )
    assert_equal( Piece.empty, p2.down )
    p2 = TwoSidedPiece.new( Piece.red, Piece.blue )
    p2dup = p2.dup
    assert_equal( p2, p2dup )
    p2dup.become( TwoSidedPiece.new( Piece.white, Piece.black ) )
    assert_not_equal( p2, p2dup )
  end

  def test_empty
    p2 = TwoSidedPiece.empty
    assert( p2.empty? )
    assert_equal( Piece.empty, p2.up )
    assert_equal( Piece.empty, p2.down )
  end
end

class TestBoard < Test::Unit::TestCase
  def test_initialize
    b = Board.new
    assert_equal( 8, b.width )
    assert_equal( 8, b.height )

    b = Board.new( 7 )
    assert_equal( 7, b.width )
    assert_equal( 8, b.height )

    b = Board.new( 7, 6 )
    assert_equal( 7, b.width )
    assert_equal( 6, b.height )

    b = Board.new( 8, 8, TwoSidedPiece )
    assert_equal( 8, b.width )
    assert_equal( 8, b.height )
    assert_equal( Piece.empty, b[0,0] )
    assert_equal( TwoSidedPiece.empty, b[0,0] )
    assert( b[0,0].empty? )
  end

  def test_twosided
    b = Board.new( 8, 8, TwoSidedPiece )
    b[0,0] = TwoSidedPiece.new( Piece.black, Piece.white )
    assert_equal( Piece.black, b[0,0] )
    assert_equal( Piece.white, b[0,0].flip! )
    b[0,0] = Piece.black
    assert_equal( Piece.black, b[0,0] )
    assert_equal( Piece.black, b[0,0].up )
    assert_equal( Piece.white, b[0,0].down )
    b[0,0] = Piece.empty
    assert_equal( Piece.empty, b[0,0] )
    assert_equal( Piece.empty, b[0,0].up )
    assert_equal( Piece.empty, b[0,0].down )
  end

  def test_dup
    b1 = Board.new
    b2 = b1.dup

    assert_equal( b1, b2 )
    assert_equal( b1.coords, b2.coords )
    assert_equal( b1.count( Piece.empty ), b2.count( Piece.empty ) )

    b2[0,0] = Piece.red

    assert_not_equal( b1, b2 )
    assert_not_equal( b1.count( Piece.empty ), b2.count( Piece.empty ) )
    assert_not_equal( b1.count( Piece.red ), b2.count( Piece.red ) )

    b1 = b2.dup

    assert_equal( b1, b2 )
    assert_equal( b1.coords, b2.coords )
    assert_equal( b1.count( Piece.empty ), b2.count( Piece.empty ) )
    assert_equal( b1.count( Piece.red ), b2.count( Piece.red ) )
  end

  def test_assignment
    b = Board.new( 8, 8 )
    b[0,0] = Piece.new( [0,0], '!' )
    b[0,7] = Piece.new( [0,7], '?' )
    b[7,0] = Piece.new( [7,0], ',' )
    b[7,7] = Piece.new( [7,7], ':' )

    assert_equal( [0,0], b[0,0].name )
    assert_equal( [0,7], b[0,7].name )
    assert_equal( [7,0], b[7,0].name )
    assert_equal( [7,7], b[7,7].name )

    assert_equal( '!', b[0,0].short )
    assert_equal( '?', b[0,7].short )
    assert_equal( ',', b[7,0].short )
    assert_equal( ':', b[7,7].short )

    b[0,0] = Piece.new( [0,0], 'n' )

    assert_equal( [0,0], b[0,0].name )
    assert_equal( 'n', b[0,0].short )
  end

  def test_to_s
    str = "0 2 \n4567\n    \n1216"
    b = Board.new( 4, 4 )
    b[0,0] = Piece.new( 'Zero', '0' )
    b[2,0] = Piece.new( 'Two', '2' )
    b[0,1] = Piece.new( 'Four', '4' )
    b[1,1] = Piece.new( 'Five', '5' )
    b[2,1] = Piece.new( 'Six', '6' )
    b[3,1] = Piece.new( 'Seven', '7' )
    b[0,3] = Piece.new( 'One', '1' )
    b[1,3] = Piece.new( 'Two', '2' )
    b[2,3] = Piece.new( 'One', '1' )
    b[3,3] = Piece.new( 'Six', '6' )
  
    assert_equal( str, b.to_s )
    
    b[2,3] = Piece.new( 'Woo', '!' )
    str[5*3+2] = '!'

    assert_equal( str, b.to_s )

    b[0,0] = nil
    str[0] = " "

    assert_equal( str, b.to_s )

    b[0,0] = Piece::EMPTY
  
    assert_equal( str, b.to_s )
  end

  def test_equal
    b1 = Board.new( 4, 5 )
    b2 = Board.new( 4, 5 )
    b3 = Board.new( 5, 4 )

    assert( b1 == b2 )
    assert( b1 != b3 )

    b1[1,2] = Piece.new( 'Woo', '!' )

    assert( b1 != b2 )

    b2[1,2] = Piece.new( 'Woo', '!' )

    assert( b1 == b2 )

    b1[3,4] = Piece.new( 'Dot', '.' )
    b2[3,4] = Piece.new( 'Dot', '.' )

    assert( b1 == b2 )
  end

  def test_coords
    b = Board.new( 2, 3 )
    assert_equal( [[0,0],[1,0],[0,1],[1,1],[0,2],[1,2]], b.coords )

    b = Board.new( 3, 2 )
    assert_equal( [[0,0],[1,0],[2,0],[0,1],[1,1],[2,1]], b.coords )

    b[0,0] = Piece.red
    assert_equal( Piece.red, b[*b.coords[0]] )
  end

  def test_count
    b = Board.new( 2, 3 )
    assert_equal( 6, b.count( Piece.empty ) )
    assert_equal( 0, b.count( Piece.red ) )

    b[0,1] = Piece.red
    b[1,1] = Piece.blue
    b[1,2] = Piece.blue

    assert_equal( 3, b.count( Piece.empty ) )
    assert_equal( 1, b.count( Piece.red ) )
    assert_equal( 2, b.count( Piece.blue ) )

    b[1,1] = Piece.red
 
    assert_equal( 3, b.count( Piece.empty ) )
    assert_equal( 2, b.count( Piece.red ) )
    assert_equal( 1, b.count( Piece.blue ) )
  end

  def test_move
    b = Board.new( 3, 3 )
    b[0,0] = Piece.queen
    b[2,2] = Piece.pawn
    b.move( b[0,0], 0, 2 )
    assert_equal( Piece.empty, b[0,0] )
    assert_equal( Piece.queen, b[0,2] )
    b.move( b[0,2], 2, 2 )
    assert_equal( Piece.empty, b[0,2] )
    assert_equal( Piece.queen, b[2,2] )
  end

  def test_rotate
    b = Board.new( 3, 3 )     # abc
    b[0,0] = Piece.a          # def
    b[1,0] = Piece.b          # ghi
    b[2,0] = Piece.c
    b[0,1] = Piece.d
    b[1,1] = Piece.e
    b[2,1] = Piece.f
    b[0,2] = Piece.g
    b[1,2] = Piece.h
    b[2,2] = Piece.i

    b45 =  b.rotate(  45 )
    b90 =  b.rotate(  90 )
    b135 = b.rotate( 135 )  # need to test
    b180 = b.rotate( 180 )
    b225 = b.rotate( 225 )  # need to test
    b270 = b.rotate( 270 )  # need to test
    b315 = b.rotate( 315 )
    b360 = b.rotate( 360 )
    

    assert_equal( "abc\ndef\nghi",     b.to_s    )
    assert_equal( "a\ndb\ngec\nhf\ni", b45.to_s  )
    assert_equal( "gda\nheb\nifc",     b90.to_s  )
    assert_equal( "c\nbf\naei\ndh\ng", b315.to_s )
    assert_equal( "abc\ndef\nghi",     b360.to_s )

    b = Board.new( 2, 3 )
    b[0,0] = Piece.a
    b[1,0] = Piece.b
    b[0,1] = Piece.c
    b[1,1] = Piece.d
    b[0,2] = Piece.e
    b[1,2] = Piece.f

    b45 = b.rotate( 45 )
    b90 = b.rotate( 90 )
    b180 = b.rotate( 180 )
    b270 = b.rotate( 270 )
    b315 = b.rotate( 315 )
    b360 = b.rotate( 360 )

    assert_equal( "ab\ncd\nef",   b.to_s    )
    assert_equal( "a\ncb\ned\nf", b45.to_s  )
    assert_equal( "eca\nfdb",     b90.to_s  )
    assert_equal( "fe\ndc\nba",   b180.to_s )
    assert_equal( "bdf\nace",     b270.to_s )
    assert_equal( "b\nad\ncf\ne", b315.to_s )
    assert_equal( "ab\ncd\nef",   b360.to_s )

    b = Board.new( 3, 2 )
    b[0,0] = Piece.a
    b[1,0] = Piece.b
    b[2,0] = Piece.c
    b[0,1] = Piece.d
    b[1,1] = Piece.e
    b[2,1] = Piece.f

    b45  = b.rotate(  45 )
    b315 = b.rotate( 315 )

    assert_equal( "abc\ndef",     b.to_s    )
    assert_equal( "a\ndb\nec\nf", b45.to_s  )
    assert_equal( "c\nbf\nae\nd", b315.to_s )
  end

  def test_capture?
    b = Board.new
    b[0,0] = Piece.x
    b[1,0] = Piece.o
    b[2,0] = Piece.o
    assert( b.capture?( 3, 0, Piece.x ) )
    assert( !b.capture?( 0, 1, Piece.x ) )
    assert( !b.capture?( 4, 0, Piece.x ) )
    b[1,1] = Piece.x
    assert( b.capture?( 1, 2, Piece.o ) )
    assert( b.capture?( 0, 2, Piece.o ) )
  end

  def test_capture_set_coords
    b = Board.new
    b[2,2] = Piece.x
    b[3,3] = Piece.o
    b[4,4] = Piece.x
    b[5,5] = Piece.o
    b[6,6] = Piece.o
    b[7,7] = Piece.x
    assert_equal( [[3,3],[5,5],[6,6]], b.capture_set_coords( 4, 4 ) )
  end

  def test_capture_set
    b = Board.new
    b[6,6] = Piece.x
    b[6,5] = Piece.o
    b[6,4] = Piece.o
    b[6,3] = Piece.o
    b[6,2] = Piece.x
    assert_equal( [Piece.o,Piece.o,Piece.o], b.capture_set( 6, 2 ) )
  end

  def test_capture
    b = Board.new
    b[0,0] = Piece.x
    b[1,0] = Piece.o
    b[2,0] = Piece.x
    b.capture( 2, 0 ) { |p| p.become( Piece.empty ) }
    assert_equal( Piece.x, b[0,0] )
    assert_equal( Piece.empty, b[1,0] )
    assert_equal( Piece.x, b[2,0] )
    b[2,1] = Piece.o
    b[2,2] = Piece.o
    b[2,3] = Piece.o
    b.capture( 2, 4, Piece.x ) { |p| p.become( Piece.x ) }
    assert_equal( Piece.x, b[2,0] )
    assert_equal( Piece.x, b[2,1] )
    assert_equal( Piece.x, b[2,2] )
    assert_equal( Piece.x, b[2,3] )
    assert_equal( Piece.x, b[2,4] )
  end
end

