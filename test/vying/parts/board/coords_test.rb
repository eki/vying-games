# frozen_string_literal: true

require_relative '../../../test_helper'

class TestCoords < Minitest::Test
  include Vying::Games

  def test_initialize
    coords = Coords.new(Coords.bounds_for(3, 4))
    assert_equal(3, coords.width)
    assert_equal(4, coords.height)
  end

  def test_each
    coords = Coords.new(Coords.bounds_for(2, 3))
    a = [Coord[0, 0], Coord[1, 0], Coord[0, 1],
         Coord[1, 1], Coord[0, 2], Coord[1, 2]]
    i = 0
    coords.each do |c|
      assert_equal(a[i], c)
      i += 1
    end
  end

  def test_include
    coords = Coords.new(Coords.bounds_for(2, 3))

    assert(coords.include?(Coord[0, 0]))
    assert(coords.include?(Coord[1, 0]))
    assert(coords.include?(Coord[0, 2]))
    assert(coords.include?(Coord[1, 2]))
    assert(coords.include?(Coord[1, 1]))

    assert(!coords.include?(Coord[-1, 0]))
    assert(!coords.include?(Coord[0, -1]))
    assert(!coords.include?(Coord[-1, -1]))
    assert(!coords.include?(Coord[2, 0]))
    assert(!coords.include?(Coord[0, 3]))
    assert(!coords.include?(Coord[2, 3]))
    assert(!coords.include?(Coord[100, 100]))

    coords = Coords.new(Coords.bounds_for(2, 3),
      omit: [Coord[0, 0], Coord[1, 0], Coord[0, 2]])

    assert(!coords.include?(Coord[0, 0]))
    assert(!coords.include?(Coord[1, 0]))
    assert(!coords.include?(Coord[0, 2]))
    assert(coords.include?(Coord[1, 2]))
    assert(coords.include?(Coord[1, 1]))

    coords = Coords.new(Coords.bounds_for(2, 3),
      omit: [Coord[0, 0], Coord[1, 0]])

    assert(!coords.include?(Coord[0, 0]))
    assert(!coords.include?(Coord[1, 0]))
    assert(coords.include?(Coord[0, 2]))
    assert(coords.include?(Coord[1, 2]))
    assert(coords.include?(Coord[1, 1]))
  end

  def test_row
    coords = Coords.new(Coords.bounds_for(2, 3))

    assert_equal(2, coords.row(Coord[0, 0]).length)
    assert_equal(2, coords.row(Coord[0, 1]).length)
    assert_equal(2, coords.row(Coord[0, 2]).length)

    assert_equal([Coord[0, 0], Coord[1, 0]], coords.row(Coord[0, 0]))
    assert_equal([Coord[0, 0], Coord[1, 0]], coords.row(Coord[1, 0]))

    assert_equal([Coord[0, 1], Coord[1, 1]], coords.row(Coord[0, 1]))
    assert_equal([Coord[0, 1], Coord[1, 1]], coords.row(Coord[1, 1]))

    assert_equal([Coord[0, 2], Coord[1, 2]], coords.row(Coord[0, 2]))
    assert_equal([Coord[0, 2], Coord[1, 2]], coords.row(Coord[1, 2]))
  end

  def test_column
    coords = Coords.new(Coords.bounds_for(2, 3))

    assert_equal(3, coords.column(Coord[0, 0]).length)
    assert_equal(3, coords.column(Coord[1, 0]).length)

    col1 = [Coord[0, 0], Coord[0, 1], Coord[0, 2]]
    col2 = [Coord[1, 0], Coord[1, 1], Coord[1, 2]]

    assert_equal(col1, coords.column(Coord[0, 0]))
    assert_equal(col1, coords.column(Coord[0, 1]))
    assert_equal(col1, coords.column(Coord[0, 2]))

    assert_equal(col2, coords.column(Coord[1, 0]))
    assert_equal(col2, coords.column(Coord[1, 1]))
    assert_equal(col2, coords.column(Coord[1, 2]))
  end

  def test_diagonal
    coords = Coords.new(Coords.bounds_for(2, 3))

    diag1p = [Coord[0, 0], Coord[1, 1]]
    diag2p = [Coord[1, 0]]
    diag3p = [Coord[0, 1], Coord[1, 2]]
    diag4p = [Coord[0, 2]]

    diag1n = [Coord[0, 0]]
    diag2n = [Coord[1, 0], Coord[0, 1]]
    diag3n = [Coord[1, 1], Coord[0, 2]]
    diag4n = [Coord[1, 2]]

    assert_equal(2, coords.diagonal(Coord[0, 0], 1).length)
    assert_equal(1, coords.diagonal(Coord[1, 0], 1).length)
    assert_equal(2, coords.diagonal(Coord[0, 1], 1).length)
    assert_equal(1, coords.diagonal(Coord[0, 2], 1).length)

    assert_equal(1, coords.diagonal(Coord[0, 0], -1).length)
    assert_equal(2, coords.diagonal(Coord[1, 0], -1).length)
    assert_equal(2, coords.diagonal(Coord[1, 1], -1).length)
    assert_equal(1, coords.diagonal(Coord[1, 2], -1).length)

    assert_equal(diag1p, coords.diagonal(Coord[0, 0], 1))
    assert_equal(diag1p, coords.diagonal(Coord[1, 1], 1))

    assert_equal(diag2p, coords.diagonal(Coord[1, 0], 1))

    assert_equal(diag3p, coords.diagonal(Coord[0, 1], 1))
    assert_equal(diag3p, coords.diagonal(Coord[1, 2], 1))

    assert_equal(diag4p, coords.diagonal(Coord[0, 2], 1))

    assert_equal(diag1p, coords.diagonal(Coord[0, 0]))
    assert_equal(diag1p, coords.diagonal(Coord[1, 1]))

    assert_equal(diag2p, coords.diagonal(Coord[1, 0]))

    assert_equal(diag3p, coords.diagonal(Coord[0, 1]))
    assert_equal(diag3p, coords.diagonal(Coord[1, 2]))

    assert_equal(diag4p, coords.diagonal(Coord[0, 2]))

    assert_equal(diag1n, coords.diagonal(Coord[0, 0], -1))

    assert_equal(diag2n, coords.diagonal(Coord[1, 0], -1))
    assert_equal(diag2n, coords.diagonal(Coord[0, 1], -1))

    assert_equal(diag3n, coords.diagonal(Coord[1, 1], -1))
    assert_equal(diag3n, coords.diagonal(Coord[0, 2], -1))

    assert_equal(diag4n, coords.diagonal(Coord[1, 2], -1))
  end

  def test_neighbors
    coords = Coords.new(Coords.bounds_for(8, 8))

    n00 = [Coord[0, 1], Coord[1, 0], Coord[1, 1]]
    n70 = [Coord[6, 0], Coord[7, 1], Coord[6, 1]]
    n07 = [Coord[0, 6], Coord[1, 7], Coord[1, 6]]
    n77 = [Coord[7, 6], Coord[6, 7], Coord[6, 6]]
    n30 = [Coord[2, 0], Coord[4, 0], Coord[2, 1], Coord[3, 1], Coord[4, 1]]
    n03 = [Coord[0, 2], Coord[0, 4], Coord[1, 2], Coord[1, 3], Coord[1, 4]]
    n37 = [Coord[2, 7], Coord[4, 7], Coord[2, 6], Coord[3, 6], Coord[4, 6]]
    n73 = [Coord[7, 2], Coord[7, 4], Coord[6, 2], Coord[6, 3], Coord[6, 4]]
    n33 = [Coord[2, 3], Coord[4, 3], Coord[3, 2], Coord[3, 4],
           Coord[2, 2], Coord[4, 4], Coord[2, 4], Coord[4, 2]]

    a00 = coords.neighbors(Coord[0, 0]).reject(&:nil?)
    a70 = coords.neighbors(Coord[7, 0]).reject(&:nil?)
    a07 = coords.neighbors(Coord[0, 7]).reject(&:nil?)
    a77 = coords.neighbors(Coord[7, 7]).reject(&:nil?)
    a30 = coords.neighbors(Coord[3, 0]).reject(&:nil?)
    a03 = coords.neighbors(Coord[0, 3]).reject(&:nil?)
    a37 = coords.neighbors(Coord[3, 7]).reject(&:nil?)
    a73 = coords.neighbors(Coord[7, 3]).reject(&:nil?)
    a33 = coords.neighbors(Coord[3, 3]).reject(&:nil?)

    assert_equal(n00.sort, a00.sort)
    assert_equal(n70.sort, a70.sort)
    assert_equal(n07.sort, a07.sort)
    assert_equal(n77.sort, a77.sort)
    assert_equal(n30.sort, a30.sort)
    assert_equal(n03.sort, a03.sort)
    assert_equal(n37.sort, a37.sort)
    assert_equal(n73.sort, a73.sort)
    assert_equal(n33.sort, a33.sort)

    assert_equal([Coord[4, 3]], coords.neighbors(Coord[4, 4], [:n]))
    assert_equal([Coord[4, 5]], coords.neighbors(Coord[4, 4], [:s]))
    assert_equal([Coord[3, 4]], coords.neighbors(Coord[4, 4], [:w]))
    assert_equal([Coord[5, 4]], coords.neighbors(Coord[4, 4], [:e]))
    assert_equal([Coord[5, 3]], coords.neighbors(Coord[4, 4], [:ne]))
    assert_equal([Coord[3, 3]], coords.neighbors(Coord[4, 4], [:nw]))
    assert_equal([Coord[5, 5]], coords.neighbors(Coord[4, 4], [:se]))
    assert_equal([Coord[3, 5]], coords.neighbors(Coord[4, 4], [:sw]))

    n44nssw = [Coord[4, 3], Coord[4, 5], Coord[3, 5]]

    assert_equal(n44nssw, coords.neighbors(Coord[4, 4], [:n, :s, :sw]))
  end

  def test_next
    coords = Coords.new(Coords.bounds_for(8, 8))

    assert_equal(Coord[0, 1], coords.next(Coord[0, 0], :s))
    assert_equal(Coord[1, 0], coords.next(Coord[0, 0], :e))
    assert_nil(coords.next(Coord[0, 0], :n))
    assert_nil(coords.next(Coord[0, 0], :w))

    assert_equal(Coord[7, 1], coords.next(Coord[7, 0], :s))
    assert_nil(coords.next(Coord[7, 0], :e))
    assert_nil(coords.next(Coord[7, 0], :n))
    assert_equal(Coord[6, 0], coords.next(Coord[7, 0], :w))

    assert_nil(coords.next(Coord[0, 7], :s))
    assert_equal(Coord[1, 7], coords.next(Coord[0, 7], :e))
    assert_equal(Coord[0, 6], coords.next(Coord[0, 7], :n))
    assert_nil(coords.next(Coord[0, 7], :w))

    assert_nil(coords.next(Coord[7, 7], :s))
    assert_nil(coords.next(Coord[7, 7], :e))
    assert_equal(Coord[7, 6], coords.next(Coord[7, 7], :n))
    assert_equal(Coord[6, 7], coords.next(Coord[7, 7], :w))
  end

  def test_to_s
    coords = Coords.new(Coords.bounds_for(2, 2))
    assert_equal('a1b1a2b2', coords.to_s)
  end

  def test_dup
    coords = Coords.new(Coords.bounds_for(3, 5))
    assert_equal(coords, coords.dup)
    assert_equal(coords.object_id, coords.dup.object_id)
  end

  def test_memoized
    coords1 = Coords.new(Coords.bounds_for(3, 5))
    coords2 = Coords.new(Coords.bounds_for(3, 5))
    assert_equal(coords1.object_id, coords2.object_id)

    coords1 = Coords.new(Coords.bounds_for(3, 5), omit: [Coord[0, 0]])
    coords2 = Coords.new(Coords.bounds_for(3, 5), omit: [Coord[0, 0]])
    assert_equal(coords1.object_id, coords2.object_id)

    coords1 = Coords.new(Coords.bounds_for(3, 5), directions: [:n, :s])
    coords2 = Coords.new(Coords.bounds_for(3, 5), directions: [:n, :s])
    assert_equal(coords1.object_id, coords2.object_id)
  end

  def test_marshal
    coords = Coords.new(Coords.bounds_for(3, 5))
    assert_equal(coords.object_id,
      Marshal.load(Marshal.dump(coords)).object_id)
    assert_equal(coords, Marshal.load(Marshal.dump(coords)))
  end
end
