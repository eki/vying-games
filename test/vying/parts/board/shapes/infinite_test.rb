
# frozen_string_literal: true

require_relative '../../../../test_helper'

class TestBoardInfinite < Minitest::Test
  include Vying

  def test_initialize
    b = Board.infinite(4, 5)
    assert_equal(:infinite, b.shape)
    assert_equal(:square, b.cell_shape)
    assert_equal([:n, :e, :w, :s, :ne, :nw, :se, :sw], b.directions)
    assert_equal(4, b.width)
    assert_equal(5, b.height)
    assert_equal([], b.coords.omitted)
    assert_equal([Coord[-1, -2], Coord[2, 2]], b.bounds)
    assert_equal([Coord[0, 0], Coord[0, 0]], b.bounds_occupied)

    assert_equal(20, b.unoccupied.length)
    assert_equal(20, b.empty_count)
    assert(b.unoccupied.include?(Coord[0, 0]))
    assert(b.unoccupied.include?(Coord[-1, -2]))
    assert(b.unoccupied.include?(Coord[2, 2]))
    assert(b.unoccupied.include?(Coord[-1, 2]))
    assert(b.unoccupied.include?(Coord[2, -2]))

    b = Board.infinite(4, 5, cell_shape: :triangle)
    assert_equal(:infinite, b.shape)
    assert_equal(:triangle, b.cell_shape)
    assert_equal(4, b.width)
    assert_equal(5, b.height)

    b = Board.infinite(4, cell_shape: :triangle)
    assert_equal(:infinite, b.shape)
    assert_equal(:triangle, b.cell_shape)
    assert_equal(4, b.width)
    assert_equal(11, b.height)

    b = Board.infinite(cell_shape: :triangle)
    assert_equal(:infinite, b.shape)
    assert_equal(:triangle, b.cell_shape)
    assert_equal(11, b.width)
    assert_equal(11, b.height)

    assert_raises(RuntimeError) do
      Board.infinite(4, 5, cell_shape: :nonexistant)
    end

    assert_raises(RuntimeError) do
      Board.infinite(4, 5, cell_shape: :triangle,
                            directions: [:n, :e, :w, :s])
    end

    b = Board.infinite(4, 5, cell_shape: :triangle)
    assert_equal(:infinite, b.shape)
    assert_equal(:triangle, b.cell_shape)
    assert_equal([:w, :e, :s], b.directions([0, 0]))
    assert_equal([:n, :e, :w], b.directions([1, 0]))
    assert_equal([:n, :e, :w], b.directions([-1, 0]))
    assert_equal([:w, :e, :s], b.directions([-2, 0]))

    assert_equal([:n, :e, :w], b.directions([0, -1]))
    assert_equal([:w, :e, :s], b.directions([1, -1]))
    assert_equal([:w, :e, :s], b.directions([-1, -1]))
    assert_equal([:n, :e, :w], b.directions([-2, -1]))

    assert_equal([Coord[1, -1], Coord[0, 0], Coord[2, 0]].sort,
                  b.coords.neighbors(Coord[1, 0]).sort)

    b = Board.infinite(4, 5, cell_shape: :hexagon)
    assert_equal(:infinite, b.shape)
    assert_equal(:hexagon, b.cell_shape)
    assert_equal(:horizontal, b.cell_orientation)
    assert_equal([:n, :e, :w, :s, :nw, :se], b.directions)

    b = Board.infinite(4, 5, cell_shape: :hexagon,
                              cell_orientation: :vertical)
    assert_equal(:infinite, b.shape)
    assert_equal(:hexagon, b.cell_shape)
    assert_equal(:vertical, b.cell_orientation)
    assert_equal([:n, :e, :w, :s, :ne, :sw], b.directions)
  end

  def test_coords
    b = Board.infinite(4, 5)

    assert_equal(4, b.width)
    assert_equal(5, b.height)

    assert_equal(4, b.coords.width)
    assert_equal(5, b.coords.height)

    assert_equal([Coord[-1, -2], Coord[2, 2]].sort, b.bounds.sort)
    assert_equal([Coord[-1, -2], Coord[2, 2]].sort, b.coords.bounds.sort)

    assert(b.coords.include?(Coord[-1, -2]))
    assert(b.coords.include?(Coord[2, 2]))
    assert(b.coords.include?(Coord[-1, 2]))
    assert(b.coords.include?(Coord[2, -2]))
    assert(b.coords.include?(Coord[0, 0]))
  end

  def test_resize
    b = Board.infinite(4, 5)

    assert_equal(4, b.width)
    assert_equal(5, b.height)

    assert_equal(4, b.coords.width)
    assert_equal(5, b.coords.height)

    assert_equal([Coord[-1, -2], Coord[2, 2]].sort, b.bounds.sort)
    assert_equal([Coord[-1, -2], Coord[2, 2]].sort, b.coords.bounds.sort)

    assert(b.coords.include?(Coord[-1, -2]))
    assert(b.coords.include?(Coord[2, 2]))
    assert(b.coords.include?(Coord[-1, 2]))
    assert(b.coords.include?(Coord[2, -2]))
    assert(b.coords.include?(Coord[0, 0]))

    b[0, 0] = :x

    assert_equal(4, b.width)
    assert_equal(5, b.height)

    assert_equal(4, b.coords.width)
    assert_equal(5, b.coords.height)

    assert_equal([Coord[-1, -2], Coord[2, 2]].sort, b.bounds.sort)
    assert_equal([Coord[-1, -2], Coord[2, 2]].sort, b.coords.bounds.sort)

    assert_equal([Coord[0, 0], Coord[0, 0]], b.bounds_occupied)

    assert(b.coords.include?(Coord[-1, -2]))
    assert(b.coords.include?(Coord[2, 2]))
    assert(b.coords.include?(Coord[-1, 2]))
    assert(b.coords.include?(Coord[2, -2]))
    assert(b.coords.include?(Coord[0, 0]))

    assert_equal([Coord[0, 0]], b.occupied(:x))
    assert_equal(19, b.unoccupied.length)

    b[2, 0] = :x

    assert_equal(5, b.width)
    assert_equal(5, b.height)

    assert_equal(5, b.coords.width)
    assert_equal(5, b.coords.height)

    assert_equal([Coord[-1, -2], Coord[3, 2]].sort, b.bounds.sort)
    assert_equal([Coord[-1, -2], Coord[3, 2]].sort, b.coords.bounds.sort)

    assert_equal([Coord[0, 0], Coord[2, 0]], b.bounds_occupied)

    assert(b.coords.include?(Coord[-1, -2]))
    assert(b.coords.include?(Coord[3, 2]))
    assert(b.coords.include?(Coord[-1, 2]))
    assert(b.coords.include?(Coord[3, -2]))
    assert(b.coords.include?(Coord[0, 0]))

    assert_equal([Coord[0, 0], Coord[2, 0]].sort, b.occupied(:x).sort)
    assert_equal(23, b.unoccupied.length)

    b[-3, -5] = :x

    assert_equal(8, b.width)
    assert_equal(9, b.height)

    assert_equal(8, b.coords.width)
    assert_equal(9, b.coords.height)

    assert_equal([Coord[-4, -6], Coord[3, 2]].sort, b.bounds.sort)
    assert_equal([Coord[-4, -6], Coord[3, 2]].sort, b.coords.bounds.sort)

    assert_equal([Coord[-3, -5], Coord[2, 0]], b.bounds_occupied)

    assert(b.coords.include?(Coord[-4, -6]))
    assert(b.coords.include?(Coord[3, 2]))
    assert(b.coords.include?(Coord[-4, 2]))
    assert(b.coords.include?(Coord[3, -6]))
    assert(b.coords.include?(Coord[0, 0]))

    assert_equal([Coord[0, 0], Coord[2, 0], Coord[-3, -5]].sort,
                  b.occupied(:x).sort)
    assert_equal(69, b.unoccupied.length)
  end

  def test_resize_02 # Based on a bug report
    b = Board.infinite(11, 11)

    b[-1, -1] = :fixed
    b[0, 0] = :mobile

    assert_equal(:fixed, b[-1, -1])
    assert_equal(:mobile, b[0, 0])
    assert_equal([Coord[-5, -5], Coord[5, 5]], b.bounds)

    assert_equal(11, b.width)
    assert_equal(11, b.height)
    assert_equal(11, b.coords.width)
    assert_equal(11, b.coords.height)

    b[-3, -3] = :x

    assert_equal(:fixed, b[-1, -1])
    assert_equal(:mobile, b[0, 0])
    assert_equal([Coord[-5, -5], Coord[5, 5]], b.bounds)

    assert_equal(11, b.width)
    assert_equal(11, b.height)
    assert_equal(11, b.coords.width)
    assert_equal(11, b.coords.height)

    b[-4, -4] = :y

    assert_equal(:fixed, b[-1, -1])
    assert_equal(:mobile, b[0, 0])
    assert_equal([Coord[-5, -5], Coord[5, 5]], b.bounds)

    assert_equal(11, b.width)
    assert_equal(11, b.height)
    assert_equal(11, b.coords.width)
    assert_equal(11, b.coords.height)

    b[-5, -5] = :z

    assert_equal(:fixed, b[-1, -1])
    assert_equal(:mobile, b[0, 0])
    assert_equal([Coord[-6, -6], Coord[5, 5]], b.bounds)

    assert_equal(12, b.width)
    assert_equal(12, b.height)
    assert_equal(12, b.coords.width)
    assert_equal(12, b.coords.height)
  end
end
