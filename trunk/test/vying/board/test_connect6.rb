require 'test/unit'

require 'vying'

class TestConnect6Board < Test::Unit::TestCase
  def test_initialize
    b = Connect6Board.new
    assert_equal( 19, b.width )
    assert_equal( 19, b.height )
    assert_equal( nil, b.occupied[:black] )
    assert_equal( nil, b.occupied[:white] )
    assert_equal( [], b.threats )
  end

  def test_dup
    b = Connect6Board.new
    b2 = b.dup

    b[10,10] = b[9,9] = b[8,8] = :black
    b.update_threats( Coord[10,10] )
    b.update_threats( Coord[9,9] )
    b.update_threats( Coord[8,8] )
    
    assert_not_equal( b, b2 )
    assert_not_equal( b.threats, b2.threats )
  end

  def test_create_windows
    b = Connect6Board.new

    [[:n,:s],[:e,:w],[:ne,:sw],[:nw,:se]].each do |d|
      ws = b.create_windows( Coord[9,9], d )
      assert_equal( 6, ws.length )
      ws.each do |w|
        assert( w.include?( Coord[9,9] ) )
      end
    end
  end

  def test_in_bounds
    b = Connect6Board.new

    w = [Coord[1,1],Coord[2,2],Coord[3,3]]
    assert( b.in_bounds?( w ) )
  end
end
