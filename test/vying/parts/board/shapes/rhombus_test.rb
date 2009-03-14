
require 'test/unit'
require 'vying'

class TestBoardRhombus < Test::Unit::TestCase
  include Vying

  def test_initialize
    b = Board.rhombus( 4, 5 )
    assert_equal( :rhombus, b.shape )
    assert_equal( 4, b.width )
    assert_equal( 5, b.height )
    assert_equal( [], b.coords.omitted )

    assert_raise( RuntimeError ) do
      Board.rhombus( 4, 5, :cell_shape => :square )
    end

    assert_raise( RuntimeError ) do
      Board.rhombus( 4, 5, :cell_shape => :triangle )
    end

    assert_raise( RuntimeError ) do
      Board.rhombus( 4, 5, :cell_shape => :nonexistant )
    end

    assert_raise( RuntimeError ) do
      Board.rhombus( 4, 5, :cell_orientation => :nonexistant )
    end

  end

end

