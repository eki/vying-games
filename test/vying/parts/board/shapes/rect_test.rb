
# frozen_string_literal: true

require_relative '../../../../test_helper'

class TestBoardRect < Minitest::Test
  include Vying

  def test_initialize
    b = Board.rect(7, 6)
    assert_equal(:rect, b.shape)
    assert_equal(7, b.width)
    assert_equal(6, b.height)
    assert_equal([], b.coords.omitted)

    assert_raises(RuntimeError) do
      Board.rect(4, 5, cell_shape: :hexagon)
    end

    assert_raises(RuntimeError) do
      Board.rect(4, 5, cell_shape: :nonexistant)
    end

    assert_raises(RuntimeError) do
      Board.rect(4, 5, cell_shape: :triangle,
                        directions: [:n, :e, :w, :s])
    end
  end
end
