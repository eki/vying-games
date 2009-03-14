
require 'test/unit'
require 'vying'

class TestBoardHexagon < Test::Unit::TestCase
  include Vying

  def test_initialize
    b = Board.hexagon( 4 )
    assert_equal( :hexagon, b.shape )
    assert_equal( 7, b.width )
    assert_equal( 7, b.height )
    assert_equal( 4, b.length )
    assert_equal( 37, b.coords.length )
    assert_equal( 12, b.coords.omitted.length )
    assert_equal( ["a1", "a2", "a3", "a4", "b1", "b2", "b3", "b4", "b5", "c1",
                   "c2", "c3", "c4", "c5", "c6", "d1", "d2", "d3", "d4", "d5",
                   "d6", "d7", "e2", "e3", "e4", "e5", "e6", "e7", "f3", "f4",
                   "f5", "f6", "f7", "g4", "g5", "g6", "g7"],
                  b.coords.map { |c| c.to_s }.sort )

    assert_equal( ["a5", "a6", "a7", "b6", "b7", "c7", "e1", "f1", "f2", "g1",
                   "g2", "g3"],
                  b.coords.omitted.map { |c| c.to_s }.sort )

    assert_raise( RuntimeError ) do
      Board.hexagon( 4, :cell_shape => :square )
    end

    assert_raise( RuntimeError ) do
      Board.hexagon( 4, :cell_shape => :triangle )
    end

    assert_raise( RuntimeError ) do
      Board.hexagon( 4, :cell_shape => :nonexistant )
    end

    assert_raise( RuntimeError ) do
      Board.hexagon( 4, :cell_orientation => :nonexistant )
    end
  end

end

