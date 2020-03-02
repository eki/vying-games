# frozen_string_literal: true

require_relative '../../../../test_helper'

class TestAmazons < Minitest::Test
  include Vying::Games

  def test_initialize_01
    b = Board.square(4, plugins: [:amazons])

    assert((class << b; ancestors; end).include?(Board::Plugins::Amazons))
    assert_equal(1, b.territories.length)
    assert_equal([], b.territories.first.black)
    assert_equal([], b.territories.first.white)
    assert_equal(b.coords.to_a, b.territories.first.coords)
  end

  def test_dup
    b = Board.square(4, plugins: [:amazons])

    assert((class << b; ancestors; end).include?(Board::Plugins::Amazons))

    b2 = b.dup

    assert((class << b2; ancestors; end).include?(Board::Plugins::Amazons))

    assert_equal(b, b2)
    assert_equal(b.territories, b2.territories)
    refute_equal(b.territories.object_id, b2.territories.object_id)
  end

  def test_marshal
    b = Board.square(4, plugins: [:amazons])

    assert((class << b; ancestors; end).include?(Board::Plugins::Amazons))

    b2 = Marshal.load(Marshal.dump(b))

    assert((class << b2; ancestors; end).include?(Board::Plugins::Amazons))

    assert_equal(b, b2)
    assert_equal(b.territories, b2.territories)
    refute_equal(b.territories.object_id, b2.territories.object_id)
  end

  def test_initialize_02
    b = Board.square(10, plugins: [:amazons])

    b[:a4, :d1, :g1, :j4] = :white
    b[:a7, :g10, :d10, :j7] = :black

    assert_equal(10, b.width)
    assert_equal(10, b.height)

    assert_equal(:white, b[0, 3])
    assert_equal(:white, b[3, 0])
    assert_equal(:white, b[6, 0])
    assert_equal(:white, b[9, 3])

    assert_equal(:black, b[0, 6])
    assert_equal(:black, b[6, 9])
    assert_equal(:black, b[3, 9])
    assert_equal(:black, b[9, 6])

    assert_equal(1, b.territories.length)
    assert_equal(92, b.territories.first.coords.length)
  end

  def test_territory_splits
    b = Board.square(10, plugins: [:amazons])

    b[:a4, :d1, :g1, :j4] = :white
    b[:a7, :g10, :d10, :j7] = :black

    a4 = Coord[:a4]
    d1 = Coord[:d1]
    g1 = Coord[:g1]
    j4 = Coord[:j4]

    a7  = Coord[:a7]
    d10 = Coord[:d10]
    g10 = Coord[:g10]
    j7  = Coord[:j7]

    assert_equal(1, b.territories.length)
    assert_equal([a4, d1, g1, j4].sort, b.territories.first.white.sort)
    assert_equal([a7, d10, g10, j7].sort, b.territories.first.black.sort)

    b.arrow(:f1, :f2, :f3, :f4, :f5, :f6, :f7, :f8, :f9, :f10)

    assert_equal(2, b.territories.length)
    assert_equal([a4, d1].sort, b.territories.first.white.sort)
    assert_equal([a7, d10].sort, b.territories.first.black.sort)
    assert_equal([g1, j4].sort, b.territories.last.white.sort)
    assert_equal([g10, j7].sort, b.territories.last.black.sort)

    b.arrow(:a2, :b2, :c2, :d2, :e2, :f2, :g2, :h2, :i2, :j2)

    assert_equal(5, b.territories.length)

    assert_equal([d1], b.territories[0].white)
    assert_equal([], b.territories[0].black)

    assert_equal([a4], b.territories[1].white)
    assert_equal([a7, d10].sort, b.territories[1].black.sort)

    assert_equal([d1], b.territories[2].white)
    assert_equal([], b.territories[2].black)

    assert_equal([g1], b.territories[3].white)
    assert_equal([], b.territories[3].black)

    assert_equal([j4], b.territories[4].white)
    assert_equal([g10, j7].sort, b.territories[4].black.sort)

    a1 = Coord[:a1]
    b1 = Coord[:b1]
    c1 = Coord[:c1]
    e1 = Coord[:e1]

    assert_equal([c1, b1, a1].sort, b.territories[0].coords.sort)
    assert_equal([e1].sort, b.territories[2].coords.sort)
  end

  def test_territory_blocking
    b = Board.square(10, plugins: [:amazons])

    b[:a4, :d1, :g1, :j4] = :white
    b[:a7, :g10, :d10, :j7] = :black

    b.arrow(:b7, :c7, :d7, :e7, :f7, :g7, :h7, :i7)

    a4 = Coord[:a4]
    d1 = Coord[:d1]
    g1 = Coord[:g1]
    j4 = Coord[:j4]

    a7  = Coord[:a7]
    d10 = Coord[:d10]
    g10 = Coord[:g10]
    j7  = Coord[:j7]

    a5 = Coord[:a5]

    assert_equal(2, b.territories.length)
    assert_equal([a4, j4, g1, d1].sort, b.territories.first.white.sort)
    assert_equal([a7, j7].sort, b.territories.first.black.sort)
    assert_equal([d10, a7, g10, j7].sort, b.territories.last.black.sort)
    assert_equal(56, b.territories.first.coords.uniq.length)
    assert_equal(28, b.territories.last.coords.uniq.length)
    assert(b.territories.first.coords.all? { |c| c.y < 6 })
    assert(b.territories.last.coords.all? { |c| c.y > 6 })

    b.move(a7, a5)

    b.territories.each do |t|
      assert(!t.black.include?(a7))
      assert(!t.coords.include?(a5))
    end

    assert(b.territories.any? { |t| t.black.include?(a5) })
    assert(b.territories.any? { |t| t.coords.include?(a7) })

    assert_equal(1, b.territories.length)
    assert_equal([a4, j4, g1, d1].sort, b.territories.first.white.sort)
    assert_equal([d10, a5, g10, j7].sort, b.territories.last.black.sort)
  end

  def test_mobility_init
    b = Board.square(10, plugins: [:amazons])

    b[:a4, :d1, :g1, :j4] = :white
    b[:a7, :g10, :d10, :j7] = :black

    m_d1 = [Coord[:e1], Coord[:f1], Coord[:d2], Coord[:d3], Coord[:d4],
            Coord[:d5], Coord[:d6], Coord[:d7], Coord[:d8], Coord[:d9],
            Coord[:c1], Coord[:b1], Coord[:a1], Coord[:e2], Coord[:f3],
            Coord[:g4], Coord[:h5], Coord[:i6], Coord[:c2], Coord[:b3]]

    assert_equal(m_d1.sort, b.mobility[Coord[:d1]].sort)
  end

  def test_mobility_move_01
    b = Board.square(10, plugins: [:amazons])

    b[:a4, :d1, :g1, :j4] = :white
    b[:a7, :g10, :d10, :j7] = :black

    m_d1_b = [Coord[:e1], Coord[:f1], Coord[:d2], Coord[:d3], Coord[:d4],
              Coord[:d5], Coord[:d6], Coord[:d7], Coord[:d8], Coord[:d9],
              Coord[:c1], Coord[:b1], Coord[:a1], Coord[:e2], Coord[:f3],
              Coord[:g4], Coord[:h5], Coord[:i6], Coord[:c2], Coord[:b3]]

    m_d1_a = [Coord[:d8], Coord[:d7], Coord[:d6], Coord[:d5], Coord[:d4],
              Coord[:d3], Coord[:d2], Coord[:d1], Coord[:e9], Coord[:f9],
              Coord[:g9], Coord[:h9], Coord[:i9], Coord[:j9], Coord[:c9],
              Coord[:b9], Coord[:a9], Coord[:e8], Coord[:f7], Coord[:g6],
              Coord[:h5], Coord[:i4], Coord[:j3], Coord[:c8], Coord[:b7],
              Coord[:a6], Coord[:e10], Coord[:c10]]

    m_d10_a = [Coord[:e10], Coord[:f10], Coord[:c10], Coord[:b10], Coord[:a10],
               Coord[:e9], Coord[:f8], Coord[:g7], Coord[:h6], Coord[:i5],
               Coord[:c9], Coord[:b8]]

    assert_equal(m_d1_b.sort, b.mobility[Coord[:d1]].sort)

    b.move(Coord[:d1], Coord[:d9])

    assert_equal(m_d1_a.sort, b.mobility[Coord[:d9]].sort)
    assert_equal(m_d10_a.sort, b.mobility[Coord[:d10]].sort)
  end

  def test_mobility_move_02
    b = Board.square(10, plugins: [:amazons])

    b[:a4, :d1, :g1, :j4] = :white
    b[:a7, :g10, :d10, :j7] = :black

    m_d1_b = [Coord[:e1], Coord[:f1], Coord[:d2], Coord[:d3], Coord[:d4],
              Coord[:d5], Coord[:d6], Coord[:d7], Coord[:d8], Coord[:d9],
              Coord[:c1], Coord[:b1], Coord[:a1], Coord[:e2], Coord[:f3],
              Coord[:g4], Coord[:h5], Coord[:i6], Coord[:c2], Coord[:b3]]

    m_d1_a = [Coord[:e1], Coord[:f1]]

    assert_equal(m_d1_b.sort, b.mobility[Coord[:d1]].sort)

    b.arrow(:c1, :c2, :d2, :e2)

    assert_equal(m_d1_a.sort, b.mobility[Coord[:d1]].sort)
  end
end
