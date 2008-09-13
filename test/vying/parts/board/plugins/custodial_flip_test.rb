
require 'test/unit'
require 'vying'

class TestCustodialFlip < Test::Unit::TestCase

  def full_ancestors( b )
    class << b; ancestors; end
  end

  def test_initialize
    b = Board.square( 4, :plugins => [:custodial_flip] )

    assert( full_ancestors( b ).include?( Board::Plugins::Frontier ) )
    assert( full_ancestors( b ).include?( Board::Plugins::CustodialFlip ) )
    assert_equal( [], b.frontier )
  end

  def test_dup
    b = Board.square( 4, :plugins => [:custodial_flip] )

    b[:a1] = :x

    assert( full_ancestors( b ).include?( Board::Plugins::Frontier ) )
    assert( full_ancestors( b ).include?( Board::Plugins::CustodialFlip ) )

    b2 = b.dup

    assert( full_ancestors( b2 ).include?( Board::Plugins::Frontier ) )
    assert( full_ancestors( b2 ).include?( Board::Plugins::CustodialFlip ) )

    assert_equal( b, b2 )
    assert_equal( b.frontier, b2.frontier )
    assert_not_equal( b.frontier.object_id, b2.frontier.object_id )
  end

  def test_marshal
    b = Board.square( 4, :plugins => [:custodial_flip] )

    b[:a1] = :x

    assert( full_ancestors( b ).include?( Board::Plugins::Frontier ) )
    assert( full_ancestors( b ).include?( Board::Plugins::CustodialFlip ) )

    b2 = Marshal.load( Marshal.dump( b ) )

    assert( full_ancestors( b2 ).include?( Board::Plugins::Frontier ) )
    assert( full_ancestors( b2 ).include?( Board::Plugins::CustodialFlip ) )

    assert_equal( b, b2 )
    assert_equal( b.frontier, b2.frontier )
    assert_not_equal( b.frontier.object_id, b2.frontier.object_id )
  end

  def test_yaml
    b = Board.square( 4, :plugins => [:custodial_flip] )

    b[:a1] = :x

    assert( full_ancestors( b ).include?( Board::Plugins::Frontier ) )
    assert( full_ancestors( b ).include?( Board::Plugins::CustodialFlip ) )

    b2 = YAML.load( b.to_yaml )

    assert( full_ancestors( b2 ).include?( Board::Plugins::Frontier ) )
    assert( full_ancestors( b2 ).include?( Board::Plugins::CustodialFlip ) )

    assert_equal( b, b2 )
    assert_equal( b.frontier, b2.frontier )
    assert_not_equal( b.frontier.object_id, b2.frontier.object_id )
  end

  def test_will_flip_ns
    b = Board.square( 8, :plugins => [:custodial_flip] )

    b[3,3] = :black
    b[3,4] = :white

    assert(   b.will_flip?( Coord[3,5], :black ) )
    assert( ! b.will_flip?( Coord[3,5], :white ) )

    assert(   b.will_flip?( Coord[3,2], :white ) ) 
    assert( ! b.will_flip?( Coord[3,2], :black ) ) 
  end

  def test_will_flip_ew
    b = Board.square( 8, :plugins => [:custodial_flip] )

    b[3,3] = :black
    b[4,3] = :white

    assert(   b.will_flip?( Coord[5,3], :black ) )
    assert( ! b.will_flip?( Coord[5,3], :white ) )

    assert(   b.will_flip?( Coord[2,3], :white ) ) 
    assert( ! b.will_flip?( Coord[2,3], :black ) ) 

    # check flip 2 in same direction

    b[5,3] = :white

    assert(   b.will_flip?( Coord[6,3], :black ) ) 
    assert( ! b.will_flip?( Coord[6,3], :white ) ) 
  end

  def test_will_flip_nw_se
    b = Board.square( 8, :plugins => [:custodial_flip] )

    b[0,0] = :white
    b[1,1] = :black
    b[3,3] = :black
    b[4,4] = :white

    assert(   b.will_flip?( Coord[2,2], :white ) ) 
    assert( ! b.will_flip?( Coord[2,2], :black ) ) 
  end

  def test_will_flip_ne_sw
    b = Board.square( 8, :plugins => [:custodial_flip] )

    b[7,0] = :black
    b[6,1] = :white
    b[5,2] = :white
    b[3,4] = :white
    b[2,5] = :black

    assert(   b.will_flip?( Coord[4,3], :black ) )
    assert( ! b.will_flip?( Coord[4,3], :white ) )
  end

  def test_will_flip_empty
    b = Board.square( 8, :plugins => [:custodial_flip] )

    b[3,3] = :black
    b[5,5] = :white

    b.coords.each do |c| 
      assert( ! b.will_flip?( c, :black ) )
      assert( ! b.will_flip?( c, :white ) )
    end
  end

  def test_will_flip_edges
    b = Board.square( 8, :plugins => [:custodial_flip] )

    b[0,0] = b[3,0] = b[3,1] = b[7,0] = b[7,3] = :black
    b[7,7] = b[3,7] = b[3,6] = b[0,7] = b[0,3] = :white

    b.coords.each do |c| 
      assert( ! b.will_flip?( c, :black ), "#{c}, :black" )
      assert( ! b.will_flip?( c, :white ), "#{c}, :white" )
    end
  end

  def test_flip_n
    b = Board.square( 8, :plugins => [:custodial_flip] )

    b[3,3] = :black
    b[3,4] = :white

    b.custodial_flip( Coord[3,5], :black )

    assert_equal( b[3,3], :black )
    assert_equal( b[3,4], :black )
    assert_equal( b[3,5], :black )

    assert_equal( 8*8-3, b.empty_count )
  end

  def test_flip_s
    b = Board.square( 8, :plugins => [:custodial_flip] )

    b[3,3] = :black
    b[3,4] = :white

    b.custodial_flip( Coord[3,2], :white )

    assert_equal( b[3,2], :white )
    assert_equal( b[3,3], :white )
    assert_equal( b[3,4], :white )

    assert_equal( 8*8-3, b.empty_count )
  end

  def test_flip_e
    b = Board.square( 8, :plugins => [:custodial_flip] )

    b[1,3] = :black
    b[2,3] = :black
    b[3,3] = :black
    b[4,3] = :white
    b[5,3] = :white

    b.custodial_flip( Coord[0,3], :white )

    assert_equal( b[0,3], :white )
    assert_equal( b[1,3], :white )
    assert_equal( b[2,3], :white )
    assert_equal( b[3,3], :white )
    assert_equal( b[4,3], :white )
    assert_equal( b[5,3], :white )

    assert_equal( 8*8-6, b.empty_count )
  end

  def test_flip_w
    b = Board.square( 8, :plugins => [:custodial_flip] )

    b[3,3] = :black
    b[4,3] = :white
    b[5,3] = :white

    b.custodial_flip( Coord[6,3], :black )

    assert_equal( b[6,3], :black )
    assert_equal( b[3,3], :black )
    assert_equal( b[4,3], :black )
    assert_equal( b[5,3], :black )

    assert_equal( 8*8-4, b.empty_count )
  end

  def test_flip_nw_se
    b = Board.square( 8, :plugins => [:custodial_flip] )

    b[0,0] = :black
    b[1,1] = :white
    b[2,2] = :white
    b[4,4] = :white
    b[5,5] = :black

    b.custodial_flip( Coord[3,3], :black )

    assert_equal( b[0,0], :black )
    assert_equal( b[1,1], :black )
    assert_equal( b[2,2], :black )
    assert_equal( b[3,3], :black )
    assert_equal( b[4,4], :black )
    assert_equal( b[5,5], :black )

    assert_equal( 8*8-6, b.empty_count )
  end

  def test_flip_ne_sw
    b = Board.square( 8, :plugins => [:custodial_flip] )

    b[7,0] = :black
    b[6,1] = :white
    b[5,2] = :white
    b[3,4] = :white
    b[2,5] = :black

    b.custodial_flip( Coord[4,3], :black )

    assert_equal( b[7,0], :black )
    assert_equal( b[6,1], :black )
    assert_equal( b[5,2], :black )
    assert_equal( b[4,3], :black )
    assert_equal( b[3,4], :black )
    assert_equal( b[2,5], :black )

    assert_equal( 8*8-6, b.empty_count )
  end
end

