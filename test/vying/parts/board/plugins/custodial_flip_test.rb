# frozen_string_literal: true

require_relative '../../../../test_helper'

class TestCustodialFlip < Minitest::Test
  include Vying

  def full_ancestors(b)
    class << b; ancestors; end
  end

  def test_initialize
    b = Board.square(4, plugins: [:custodial_flip])

    assert(full_ancestors(b).include?(Board::Plugins::CustodialFlip))
  end

  def test_dup
    b = Board.square(4, plugins: [:custodial_flip])

    b[:a1] = :x

    assert(full_ancestors(b).include?(Board::Plugins::CustodialFlip))

    b2 = b.dup

    assert(full_ancestors(b2).include?(Board::Plugins::CustodialFlip))

    assert_equal(b, b2)
  end

  def test_marshal
    b = Board.square(4, plugins: [:custodial_flip])

    b[:a1] = :x

    assert(full_ancestors(b).include?(Board::Plugins::CustodialFlip))

    b2 = Marshal.load(Marshal.dump(b))

    assert(full_ancestors(b2).include?(Board::Plugins::CustodialFlip))

    assert_equal(b, b2)
  end

  def test_will_flip_ns
    b = Board.square(8, plugins: [:custodial_flip])

    b[3, 3] = :black
    b[3, 4] = :white

    assert(b.custodial_flip?(Coord[3, 5], :black))
    assert(!b.custodial_flip?(Coord[3, 5], :white))

    assert(b.custodial_flip?(Coord[3, 2], :white))
    assert(!b.custodial_flip?(Coord[3, 2], :black))
  end

  def test_will_flip_ew
    b = Board.square(8, plugins: [:custodial_flip])

    b[3, 3] = :black
    b[4, 3] = :white

    assert(b.custodial_flip?(Coord[5, 3], :black))
    assert(!b.custodial_flip?(Coord[5, 3], :white))

    assert(b.custodial_flip?(Coord[2, 3], :white))
    assert(!b.custodial_flip?(Coord[2, 3], :black))

    # check flip 2 in same direction

    b[5, 3] = :white

    assert(b.custodial_flip?(Coord[6, 3], :black))
    assert(!b.custodial_flip?(Coord[6, 3], :white))
  end

  def test_will_flip_nw_se
    b = Board.square(8, plugins: [:custodial_flip])

    b[0, 0] = :white
    b[1, 1] = :black
    b[3, 3] = :black
    b[4, 4] = :white

    assert(b.custodial_flip?(Coord[2, 2], :white))
    assert(!b.custodial_flip?(Coord[2, 2], :black))
  end

  def test_will_flip_ne_sw
    b = Board.square(8, plugins: [:custodial_flip])

    b[7, 0] = :black
    b[6, 1] = :white
    b[5, 2] = :white
    b[3, 4] = :white
    b[2, 5] = :black

    assert(b.custodial_flip?(Coord[4, 3], :black))
    assert(!b.custodial_flip?(Coord[4, 3], :white))
  end

  def test_will_flip_empty
    b = Board.square(8, plugins: [:custodial_flip])

    b[3, 3] = :black
    b[5, 5] = :white

    b.coords.each do |c|
      assert(!b.custodial_flip?(c, :black))
      assert(!b.custodial_flip?(c, :white))
    end
  end

  def test_will_flip_edges
    b = Board.square(8, plugins: [:custodial_flip])

    b[0, 0] = b[3, 0] = b[3, 1] = b[7, 0] = b[7, 3] = :black
    b[7, 7] = b[3, 7] = b[3, 6] = b[0, 7] = b[0, 3] = :white

    b.coords.each do |c|
      assert(!b.custodial_flip?(c, :black), "#{c}, :black")
      assert(!b.custodial_flip?(c, :white), "#{c}, :white")
    end
  end

  def test_flip_n
    b = Board.square(8, plugins: [:custodial_flip])

    b[3, 3] = :black
    b[3, 4] = :white

    cc = b.custodial_flip(Coord[3, 5], :black)

    assert_equal([Coord[3, 4]].sort, cc.sort)

    assert_equal(:black, b[3, 3])
    assert_equal(:black, b[3, 4])
    assert_equal(:black, b[3, 5])

    assert_equal(8 * 8 - 3, b.empty_count)
  end

  def test_flip_s
    b = Board.square(8, plugins: [:custodial_flip])

    b[3, 3] = :black
    b[3, 4] = :white

    cc = b.custodial_flip(Coord[3, 2], :white)

    assert_equal([Coord[3, 3]].sort, cc.sort)

    assert_equal(:white, b[3, 2])
    assert_equal(:white, b[3, 3])
    assert_equal(:white, b[3, 4])

    assert_equal(8 * 8 - 3, b.empty_count)
  end

  def test_flip_e
    b = Board.square(8, plugins: [:custodial_flip])

    b[1, 3] = :black
    b[2, 3] = :black
    b[3, 3] = :black
    b[4, 3] = :white
    b[5, 3] = :white

    cc = b.custodial_flip(Coord[0, 3], :white)

    assert_equal([Coord[1, 3], Coord[2, 3], Coord[3, 3]].sort, cc.sort)

    assert_equal(:white, b[0, 3])
    assert_equal(:white, b[1, 3])
    assert_equal(:white, b[2, 3])
    assert_equal(:white, b[3, 3])
    assert_equal(:white, b[4, 3])
    assert_equal(:white, b[5, 3])

    assert_equal(8 * 8 - 6, b.empty_count)
  end

  def test_flip_w
    b = Board.square(8, plugins: [:custodial_flip])

    b[3, 3] = :black
    b[4, 3] = :white
    b[5, 3] = :white

    cc = b.custodial_flip(Coord[6, 3], :black)

    assert_equal([Coord[4, 3], Coord[5, 3]].sort, cc.sort)

    assert_equal(:black, b[6, 3])
    assert_equal(:black, b[3, 3])
    assert_equal(:black, b[4, 3])
    assert_equal(:black, b[5, 3])

    assert_equal(8 * 8 - 4, b.empty_count)
  end

  def test_flip_nw_se
    b = Board.square(8, plugins: [:custodial_flip])

    b[0, 0] = :black
    b[1, 1] = :white
    b[2, 2] = :white
    b[4, 4] = :white
    b[5, 5] = :black

    cc = b.custodial_flip(Coord[3, 3], :black)

    assert_equal([Coord[1, 1], Coord[2, 2], Coord[4, 4]].sort, cc.sort)

    assert_equal(:black, b[0, 0])
    assert_equal(:black, b[1, 1])
    assert_equal(:black, b[2, 2])
    assert_equal(:black, b[3, 3])
    assert_equal(:black, b[4, 4])
    assert_equal(:black, b[5, 5])

    assert_equal(8 * 8 - 6, b.empty_count)
  end

  def test_flip_ne_sw
    b = Board.square(8, plugins: [:custodial_flip])

    b[7, 0] = :black
    b[6, 1] = :white
    b[5, 2] = :white
    b[3, 4] = :white
    b[2, 5] = :black

    cc = b.custodial_flip(Coord[4, 3], :black)

    assert_equal([Coord[6, 1], Coord[5, 2], Coord[3, 4]].sort, cc.sort)

    assert_equal(:black, b[7, 0])
    assert_equal(:black, b[6, 1])
    assert_equal(:black, b[5, 2])
    assert_equal(:black, b[4, 3])
    assert_equal(:black, b[3, 4])
    assert_equal(:black, b[2, 5])

    assert_equal(8 * 8 - 6, b.empty_count)
  end

  def test_no_flip
    b = Board.square(8, plugins: [:custodial_flip])

    b[7, 0] = :black
    b[7, 1] = :white

    assert(!b.custodial_flip?(Coord[6, 0], :black))

    cc = b.custodial_flip(Coord[6, 0], :black)

    assert_equal([], cc)

    assert_equal(:black, b[7, 0])
    assert_equal(:white, b[7, 1])
    assert_equal(:black, b[6, 0])

    assert_equal(8 * 8 - 3, b.empty_count)
  end

  def test_flip_range
    b = Board.square(8, plugins: [:custodial_flip])

    b[0, 0] = :black
    b[1, 1] = :white

    assert(!b.custodial_flip?(Coord[2, 2], :black, 2..4))

    cc = b.custodial_flip(Coord[2, 2], :black, 2..4)

    assert_equal([], cc)

    assert_equal(:black, b[0, 0])
    assert_equal(:white, b[1, 1])
    assert_equal(:black, b[2, 2])

    assert_equal(8 * 8 - 3, b.empty_count)

    b[2, 2] = :white

    assert(b.custodial_flip?(Coord[3, 3], :black, 2..4))

    b[3, 3] = :white

    assert(b.custodial_flip?(Coord[4, 4], :black, 2..4))

    b[4, 4] = :white

    assert(b.custodial_flip?(Coord[5, 5], :black, 2..4))

    b[5, 5] = :white

    assert(!b.custodial_flip?(Coord[6, 6], :black, 2..4))

    cc = b.custodial_flip(Coord[6, 6], :black, 2..4)

    assert_equal([], cc)

    assert_equal(:black, b[0, 0])
    assert_equal(:white, b[1, 1])
    assert_equal(:white, b[2, 2])
    assert_equal(:white, b[3, 3])
    assert_equal(:white, b[4, 4])
    assert_equal(:white, b[5, 5])
    assert_equal(:black, b[6, 6])

    assert_equal(8 * 8 - 7, b.empty_count)

    b[5, 5] = nil
    b[6, 6] = nil

    cc = b.custodial_flip(Coord[5, 5], :black)

    assert_equal([Coord[1, 1], Coord[2, 2], Coord[3, 3], Coord[4, 4]].sort,
      cc.sort)

    assert_equal(:black, b[0, 0])
    assert_equal(:black, b[1, 1])
    assert_equal(:black, b[2, 2])
    assert_equal(:black, b[3, 3])
    assert_equal(:black, b[4, 4])
    assert_equal(:black, b[5, 5])

    assert_equal(8 * 8 - 6, b.empty_count)
  end
end
