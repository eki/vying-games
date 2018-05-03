
# frozen_string_literal: true

require_relative '../../../../test_helper'

class TestBoardTriangle < Minitest::Test
  include Vying

  def test_initialize
    b = Board.triangle(4)
    assert_equal(:triangle, b.shape)
    assert_equal(4, b.width)
    assert_equal(4, b.height)
    assert_equal(4, b.length)
    assert_equal(10, b.coords.length)
    assert_equal(6, b.coords.omitted.length)
    assert_equal(%w(a1 a2 a3 a4 b1 b2 b3 c1 c2 d1),
                  b.coords.map(&:to_s).sort)
    assert_equal(%w(b4 c3 c4 d2 d3 d4),
                  b.coords.omitted.map(&:to_s).sort)

    b = Board.triangle(4, omit: %w(a1 d1))
    assert_equal(:triangle, b.shape)
    assert_equal(4, b.width)
    assert_equal(4, b.height)
    assert_equal(4, b.length)
    assert_equal(8, b.coords.length)
    assert_equal(8, b.coords.omitted.length)
    assert_equal(%w(a2 a3 a4 b1 b2 b3 c1 c2),
                  b.coords.map(&:to_s).sort)
    assert_equal(%w(a1 b4 c3 c4 d1 d2 d3 d4),
                  b.coords.omitted.map(&:to_s).sort)

    assert_raises(RuntimeError) do
      Board.triangle(4, cell_shape: :square)
    end

    assert_raises(RuntimeError) do
      Board.triangle(4, cell_shape: :triangle)
    end

    assert_raises(RuntimeError) do
      Board.triangle(4, cell_shape: :nonexistant)
    end

    assert_raises(RuntimeError) do
      Board.triangle(4, cell_orientation: :nonexistant)
    end
  end

end
