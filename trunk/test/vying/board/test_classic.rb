require 'test/unit'

require 'vying/board/classic'

class TestArray < Test::Unit::TestCase
  def test_x
    assert_equal( 2, [2,3].x )
    assert_equal( -3, [-3,0].x )
    assert_equal( 0, [0,25].x )
  end

  def test_y
    assert_equal( 3, [2,3].y )
    assert_equal( 0, [-3,0].y )
    assert_equal( 25, [0,25].y )
  end
end

class TestSymbol < Test::Unit::TestCase
  def test_x
    assert_equal( 0, :a3.x )
    assert_equal( 7, :h8.x )
    assert_equal( 1, :b10.x )
  end

  def test_y
    assert_equal( 2, :a3.y )
    assert_equal( 7, :h8.y )
    assert_equal( 9, :b10.y )
  end
end

class TestClassicBoard < Test::Unit::TestCase

  def test_initialize
    b = ClassicBoard.new( 7, 6 )
    assert_equal( 7, b.width )
    assert_equal( 6, b.height )
  end

  def test_dup
    b = ClassicBoard.new( 7, 6 )

    assert_equal( :black, b[3,4] = :black )
    b2 = b.dup

    assert_equal( :black, b2[3,4] )
    assert_equal( :white, b2[0,0] = :white )
    assert_equal( :empty, b[0,0] )
    assert_equal( :black, b[1,1] = :black )
    assert_equal( :empty, b2[1,1] )
  end

  def test_c_to_i
    b = ClassicBoard.new( 7, 6 )
    assert_equal( 29, b.c_to_i( [1,4] ) )
    assert_equal( 41, b.c_to_i( [6,5] ) )
    assert_equal( 2, b.c_to_i( [2,0] ) )
    assert_equal( 14, b.c_to_i( [0,2] ) )
    assert_equal( 8, b.c_to_i( :b2 ) )
  end

  def test_ki
    b = ClassicBoard.new( 7, 6 )
    assert_equal( 0, b.ki( :empty ) )
    assert_equal( 1, b.ki( :black ) )
    assert_equal( 2, b.ki( :white ) )
    assert_equal( 1, b.ki( :black ) )
    assert_equal( 2, b.ki( :white ) )
  end

  def test_assignment
    b = ClassicBoard.new( 7, 6 )
    assert_equal( :empty, b[3,4] )
    assert_equal( :black, b[3,4] = :black )
    assert_equal( :black, b[3,4] )
    assert_equal( :empty, b[:a1] )
    assert_equal( :white, b[:a1] = :white )
    assert_equal( :white, b[:a1] )
    assert_equal( [:black,:white,:empty], b[[3,4],:a1,:b2] )
  end


end

