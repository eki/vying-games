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

  def test_clear
    b = Connect6Board.new

    b[10,10] = b[9,9] = b[8,8] = :black
    b.update_threats( Coord[10,10] )
    b.update_threats( Coord[9,9] )
    b.update_threats( Coord[8,8] )

    assert_equal( 6, b.threats.length )

    b.clear

    assert_equal( 0, b.threats.length )
  end

  def test_threats_to_s
    b = Connect6Board.new

    b[10,10] = b[9,9] = b[8,8] = :black
    b.update_threats( Coord[10,10] )
    b.update_threats( Coord[9,9] )
    b.update_threats( Coord[8,8] )

    assert_equal( 6, b.threats.length )

    b.threats.each do |t|
      assert_equal( "[#{t.degree}, #{t.player}, #{t.empty_coords.inspect}]",
                    t.to_s )
      assert_equal( t.to_s, t.inspect )
    end
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

  def test_window_in_bounds
    b = Connect6Board.new

    w = [Coord[1,1],Coord[2,2],Coord[3,3]]
    assert( b.window_in_bounds?( w ) )
  end

  def test_has_neighbor?
    b = Connect6Board.new
    b[:c3] = :black
    assert( b.has_neighbor?( Coord[:c2] ) )
    assert( ! b.has_neighbor?( Coord[:c1] ) )
  end
end
