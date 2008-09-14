
require 'test/unit'
require 'vying'

class TestBoardRect < Test::Unit::TestCase

  def test_initialize
    b = Board.rect( 7, 6 )
    assert_equal( :rect, b.shape )
    assert_equal( 7, b.width )
    assert_equal( 6, b.height )
    assert_equal( [], b.coords.omitted )

    assert_raise( RuntimeError ) do
      Board.rect( 4, 5, :cell_shape => :hexagon )
    end

    assert_raise( RuntimeError ) do
      Board.rect( 4, 5, :cell_shape => :nonexistant )
    end

    assert_raise( RuntimeError ) do
      Board.rect( 4, 5, :cell_shape => :triangle, 
                        :directions => [:n, :e, :w, :s])
    end
  end
end

