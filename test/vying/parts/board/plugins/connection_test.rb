# frozen_string_literal: true

require_relative '../../../../test_helper'

class TestConnection < Minitest::Test
  include Vying::Games

  def test_initialize
    b = Board.square(4, plugins: [:connection])

    assert((class << b; ancestors; end).include?(Board::Plugins::Connection))
    assert_equal({}, b.groups)
    assert_equal([], b.groups[:x])
  end

  def test_dup
    b = Board.square(4, plugins: [:connection])
    b[:a1] = :x

    assert((class << b; ancestors; end).include?(Board::Plugins::Connection))

    b2 = b.dup

    assert((class << b2; ancestors; end).include?(Board::Plugins::Connection))

    assert_equal(b, b2)
    assert_equal(b.groups, b2.groups)
    refute_equal(b.groups.object_id, b2.groups.object_id)
    refute_equal(b.groups[:x].object_id, b2.groups[:x].object_id)

    bg = b.groups[:x].first
    b2g = b2.groups[:x].first

    assert_equal(bg, b2g)
    assert_equal(bg.coords, b2g.coords)

    refute_equal(bg.object_id, b2g.object_id)
    refute_equal(bg.coords.object_id, b2g.coords.object_id)
    refute_equal(bg.instance_variable_get('@board').object_id,
      b2g.instance_variable_get('@board').object_id)
  end

  def test_marshal
    b = Board.square(4, plugins: [:connection])
    b[:a1] = :x

    assert((class << b; ancestors; end).include?(Board::Plugins::Connection))

    b2 = Marshal.load(Marshal.dump(b))

    assert((class << b2; ancestors; end).include?(Board::Plugins::Connection))

    assert_equal(b, b2)
    assert_equal(b.groups, b2.groups)
    refute_equal(b.groups.object_id, b2.groups.object_id)
    refute_equal(b.groups[:x].object_id, b2.groups[:x].object_id)

    bg = b.groups[:x].first
    b2g = b2.groups[:x].first

    assert_equal(bg, b2g)
    assert_equal(bg.coords, b2g.coords)

    refute_equal(bg.object_id, b2g.object_id)
    refute_equal(bg.coords.object_id, b2g.coords.object_id)
    refute_equal(bg.instance_variable_get('@board').object_id,
      b2g.instance_variable_get('@board').object_id)
  end

  def test_clear
    b = Board.square(4, plugins: [:connection])

    b[:a1, :a2, :a3] = :black

    assert_equal(1, b.groups[:black].length)

    b.clear

    assert_equal(0, b.groups[:black].length)
  end

  def test_groups_01
    b = Board.square(4, plugins: [:connection])

    assert(b.groups[:x].empty?)

    b[:a1] = :x

    assert_equal(1, b.groups[:x].length)
    assert_equal([Coord[:a1]], b.groups[:x].first.coords)

    b[:a2] = :x

    assert_equal(1, b.groups[:x].length)
    assert_equal([Coord[:a1], Coord[:a2]].sort,
      b.groups[:x].first.coords.sort)

    b[:a4] = :x

    assert_equal(2, b.groups[:x].length)
    assert(b.groups[:x].any? do |g|
      [Coord[:a1], Coord[:a2]].sort == g.coords.sort
    end)
    assert(b.groups[:x].any? { |g| [Coord[:a4]].sort == g.coords.sort })

    b[:a3] = :x

    assert_equal(1, b.groups[:x].length)
    assert_equal([Coord[:a1], Coord[:a2], Coord[:a3], Coord[:a4]].sort,
      b.groups[:x].first.coords.sort)
  end

  def test_groups_02
    b = Board.square(4, plugins: [:connection])

    assert(b.groups[:x].empty?)

    b[:a1] = :x

    assert_equal(1, b.groups[:x].length)
    assert_equal([Coord[:a1]], b.groups[:x].first.coords)

    b[:a2] = :o

    assert_equal(1, b.groups[:x].length)
    assert_equal([Coord[:a1]], b.groups[:x].first.coords)

    assert_equal(1, b.groups[:o].length)
    assert_equal([Coord[:a2]], b.groups[:o].first.coords)
  end

  def test_groups_03
    b = Board.square(4, plugins: [:connection])

    assert(b.groups[:x].empty?)

    b[:a1, :a2, :a3, :a4] = :x

    assert_equal(1, b.groups[:x].length)
    assert_equal([:a1, :a2, :a3, :a4].map { |c| Coord[c] }.sort,
      b.groups[:x].first.coords)

    b[:a3] = nil

    assert_equal(2, b.groups[:x].length)
    assert(b.groups[:x].any? do |g|
      [Coord[:a1], Coord[:a2]].sort == g.coords.sort
    end)
    assert(b.groups[:x].any? { |g| [Coord[:a4]].sort == g.coords.sort })

    assert(b.groups[:x].none? { |g| g.coords.include?(Coord[:a3]) })
  end

  def test_groups_04
    b = Board.square(4, plugins: [:connection])

    assert(b.groups[:x].empty?)

    b[:a1, :a2, :a3, :a4] = :x

    assert_equal(1, b.groups[:x].length)
    assert_equal([:a1, :a2, :a3, :a4].map { |c| Coord[c] }.sort,
      b.groups[:x].first.coords)

    b[:a3] = :o

    assert_equal(2, b.groups[:x].length)
    assert(b.groups[:x].any? do |g|
      [Coord[:a1], Coord[:a2]].sort == g.coords.sort
    end)
    assert(b.groups[:x].any? { |g| [Coord[:a4]].sort == g.coords.sort })

    assert(b.groups[:x].none? { |g| g.coords.include?(Coord[:a3]) })

    assert_equal(1, b.groups[:o].length)
    assert_equal([Coord[:a3]], b.groups[:o].first.coords)
  end

  def test_groups_05
    b = Board.square(4, plugins: [:connection])

    assert(b.groups[:x].empty?)

    b[:a1] = :x

    assert_equal(1, b.groups[:x].length)
    assert_equal([Coord[:a1]], b.groups[:x].first.coords)

    b[:a1] = :x

    assert_equal(1, b.groups[:x].length)
    assert_equal([Coord[:a1]], b.groups[:x].first.coords)
  end

end
