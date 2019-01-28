# frozen_string_literal: true

require_relative '../../../../test_helper'

class TestInARow < Minitest::Test
  include Vying

  def test_initialize
    b = Board.square(4, plugins: [:in_a_row])

    assert((class << b; ancestors; end).include?(Board::Plugins::InARow))
    assert_equal([], b.threats)
    assert_nil(b.window_size)
  end

  def test_set_window_size
    b = Board.square(4, plugins: [:in_a_row])
    b.window_size = 4
    assert_equal(4, b.window_size)
  end

  def test_dup
    b = Board.square(4, plugins: [:in_a_row])
    b.window_size = 4

    assert((class << b; ancestors; end).include?(Board::Plugins::InARow))

    b2 = b.dup

    assert((class << b2; ancestors; end).include?(Board::Plugins::InARow))

    assert_equal(b, b2)
    assert_equal(b.window_size, b2.window_size)
    assert_equal(b.threats, b2.threats)
    refute_equal(b.threats.object_id, b2.threats.object_id)
  end

  def test_marshal
    b = Board.square(4, plugins: [:in_a_row])
    b.window_size = 4

    assert((class << b; ancestors; end).include?(Board::Plugins::InARow))

    b2 = Marshal.load(Marshal.dump(b))

    assert((class << b2; ancestors; end).include?(Board::Plugins::InARow))

    assert_equal(b, b2)
    assert_equal(b.window_size, b2.window_size)
    assert_equal(b.threats, b2.threats)
    refute_equal(b.threats.object_id, b2.threats.object_id)
  end

  def test_clear
    b = Board.square(4, plugins: [:in_a_row])
    b.window_size = 4

    b[:a1, :a2, :a3] = :black

    assert_equal(1, b.threats.length)

    b.clear

    assert_equal(0, b.threats.length)
  end

  def test_threats_to_s
    b = Board.square(19, plugins: [:in_a_row])
    b.window_size = 6

    b[10, 10] = b[9, 9] = b[8, 8] = :black

    assert_equal(6, b.threats.length)

    b.threats.each do |t|
      assert_equal("[#{t.degree}, #{t.player}, #{t.empty_coords.inspect}]",
                    t.to_s)
      assert_equal(t.to_s, t.inspect)
    end
  end

  def test_create_windows
    b = Board.square(19, plugins: [:in_a_row])
    b.window_size = 6

    ws = b.send(:create_windows, Coord[9, 9])
    assert_equal(6 * 4, ws.length)
    ws.each do |w|
      assert(w.include?(Coord[9, 9]))
    end
  end

  def test_window_in_bounds
    b = Board.square(19, plugins: [:in_a_row])
    b.window_size = 6

    w = [Coord[1, 1], Coord[2, 2], Coord[3, 3]]
    assert(b.send(:window_in_bounds?, w))
  end

  def test_has_neighbor?
    b = Board.square(19, plugins: [:in_a_row])
    b.window_size = 6

    b[:c3] = :black
    assert(b.send(:has_neighbor?, Coord[:c2]))
    assert(!b.send(:has_neighbor?, Coord[:c1]))
  end
end
