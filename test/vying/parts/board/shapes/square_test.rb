# frozen_string_literal: true

require_relative '../../../../test_helper'

class TestBoardSquare < Minitest::Test
  include Vying::Games

  def test_initialize
    b = Board.square(8)
    assert_equal(:square, b.shape)
    assert_equal(8, b.width)
    assert_equal(8, b.height)
    assert_equal(8, b.length)
    assert_equal([], b.coords.omitted)

    b = Board.square(8, omit: [:d3, :d4])
    assert_equal(:square, b.shape)
    assert_equal(8, b.width)
    assert_equal(8, b.height)
    assert_equal(8, b.length)
    assert_equal(%w(d3 d4), b.coords.omitted.map(&:to_s).sort)
    assert_equal(62, b.coords.length)
    assert(!b.coords.include?(Coord[:d3]))
    assert(!b.coords.include?(Coord[:d4]))

    b = Board.square(5, cell_shape: :triangle)
    assert_equal(:square, b.shape)
    assert_equal(:triangle, b.cell_shape)

    assert_raises(RuntimeError) do
      Board.square(4, cell_shape: :hexagon)
    end

    assert_raises(RuntimeError) do
      Board.square(4, cell_shape: :nonexistant)
    end

    assert_raises(RuntimeError) do
      Board.square(4, cell_shape: :triangle,
                       directions: [:n, :e, :w, :s])
    end
  end
end
