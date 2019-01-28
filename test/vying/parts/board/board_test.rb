# frozen_string_literal: true

require_relative '../../../test_helper'

class TestBoard < Minitest::Test
  include Vying

  def test_initialize
    assert_raises(NoMethodError) do
      Board.new
    end
  end

  def test_bad_subscripts
    b = Board.rect(7, 6)
    assert_nil(b[-1, 0])
    assert_nil(b[0, -1])
    assert_nil(b[-1, -1])
    assert_nil(b[7, 0])
    assert_nil(b[7, 6])
    assert_nil(b[0, 6])
    assert_equal(:black, b[0, 6] = :black)
    assert_nil(b[0, 6])
    assert_nil(b[nil])
  end

  def test_ci
    b = Board.rect(7, 6)
    assert_equal(0, b.send(:ci, 0, 0))
    assert_equal(2, b.send(:ci, 2, 0))
    assert_equal(14, b.send(:ci, 0, 2))
    assert_equal(17, b.send(:ci, 3, 2))
  end

  def test_dup
    b = Board.rect(7, 6)

    assert_equal(:black, b[3, 4] = :black)
    b2 = b.dup

    assert_equal(Board::Rect, b.class)
    assert_equal(Board::Rect, b2.class)

    assert_equal(:black, b2[3, 4])
    assert_equal(:white, b2[0, 0] = :white)
    assert_nil(b[0, 0])
    assert_equal(:black, b[1, 1] = :black)
    assert_nil(b2[1, 1])
    refute_equal(b, b2)

    assert_equal(:black, b2[1, 1] = :black)
    assert_equal(:white, b[0, 0] = :white)
    assert_equal(b, b2)

    assert_equal(:blue, b[0, 0] = :blue)
    assert_equal(:red, b[0, 1] = :red)

    assert_equal(:red, b2[0, 0] = :red)
    assert_equal(:blue, b2[0, 1] = :blue)

    assert_nil(b2[0, 0] = nil)
    assert_nil(b2[0, 1] = nil)

    refute_equal(b, b2) # Are they sharing key?
  end

  def test_assignment
    b = Board.rect(7, 6)
    assert_nil(b[3, 4])
    assert_equal(:black, b[3, 4] = :black)
    assert_equal(:black, b[3, 4])

    assert_nil(b[:a1])
    assert_equal(:white, b[:a1] = :white)
    assert_equal(:white, b[:a1])

    assert_nil(b[Coord[2, 2]])
    assert_equal(:white, b[Coord[2, 2]] = :white)
    assert_equal(:white, b[Coord[2, 2]])

    assert_equal([:black, :white, nil, :white], b[[3, 4], :a1, :b2, Coord[2, 2]])
  end

  def test_in_bounds
    b = Board.rect(7, 6)
    assert(b.in_bounds?(0, 0))
    assert(b.in_bounds?(6, 0))
    assert(b.in_bounds?(0, 5))
    assert(b.in_bounds?(6, 5))

    assert_nil(b.in_bounds?(-1, 0))
    assert_nil(b.in_bounds?(0, -1))
    assert_nil(b.in_bounds?(7, 0))
    assert_nil(b.in_bounds?(0, 6))
  end

  def test_equals
    b1 = Board.rect(7, 6)
    b2 = Board.rect(7, 6)
    b3 = Board.rect(6, 7)
    b4 = Board.rect(1, 2)

    assert_equal(b1, b2)

    refute_equal(b1, b3)
    refute_equal(b1, b4)

    assert_equal(b1, b1.dup)

    assert_equal(:white, b2[3, 3] = :white)
    refute_equal(b1, b2)

    assert_equal(:white, b1[3, 3] = :white)
    assert_equal(b1, b2)

    assert_equal(:blue, b1[3, 4] = :blue) # :blue added to key
    assert_equal(:red,  b2[3, 4] = :red) # :red  added to key

    refute_equal(b1, b2)
  end

  def test_hash
    b1 = Board.rect(7, 6)

    assert_equal(:black, b1[:a1, :a2, :b4, :e3] = :black)

    b2 = b1.dup

    assert_equal(b1, b2)
    assert_equal(b1.hash, b2.hash)
  end

  def test_count
    b = Board.rect(3, 4)

    assert_equal(0, b.count(:black))
    assert_equal(:black, b[:a1, :a2, :a3, :a4] = :black)
    assert_equal(4, b.count(:black))

    assert_equal(0, b.count(:white))
    assert_equal(:white, b[:b1, :b2, :b3, :b4, :c1, :c2, :c3, :c4] = :white)
    assert_equal(8, b.count(:white))

    assert_equal(0, b.count(:blue))
    assert_equal(:blue, b[:a2, :b3] = :blue)
    assert_equal(2, b.count(:blue))
    assert_equal(3, b.count(:black))
    assert_equal(7, b.count(:white))
  end

  def test_occupied
    b = Board.square(4)
    assert_equal([], b.occupied(:black))
    b[1, 1] = :black
    assert_equal([Coord[1, 1]], b.occupied(:black))
    assert_equal([], b.occupied(:white))
    b[1, 1] = :white
    assert_equal([], b.occupied(:black))
    assert_equal([Coord[1, 1]], b.occupied(:white))

    b.clear
    b[:a1] = :black
    assert_equal([Coord[:a1]], b.occupied(:black))
    assert_equal(1, b.occupied.length)
    assert_equal(15, b.unoccupied.length)
    assert_equal(15, b.empty_count)
    assert(!b.unoccupied.include?(Coord[:a1]))

    b[:a2] = :white
    assert_equal([Coord[:a1]], b.occupied(:black))
    assert_equal([Coord[:a2]], b.occupied(:white))
    assert_equal([Coord[:a1], Coord[:a2]].sort, b.occupied.sort)
    assert_equal(2, b.occupied.length)
    assert_equal(14, b.unoccupied.length)
    assert_equal(14, b.empty_count)
    assert(!b.unoccupied.include?(Coord[:a2]))

    Marshal.dump(b)
  end

  def test_each
    b = Board.square(2)
    b[0, 0] = :b00
    b[1, 0] = :b10
    b[0, 1] = :b01
    b[1, 1] = :b11

    a = [:b00, :b10, :b01, :b11]
    i = 0

    b.each do |p|
      assert_equal(a[i], p)
      i += 1
    end
  end

  def test_each_from
    b = Board.square(8)
    b[3, 3] = :x
    b[3, 4] = :x
    b[3, 6] = :x
    b[2, 2] = :o
    b[1, 1] = :o
    b[0, 0] = :o

    count1 = b.each_from(Coord[3, 3], [:nw, :s]) { |p| !p.nil? }
    count2 = b.each_from(Coord[3, 3], [:nw, :s]) { |p| p == :x }
    count3 = b.each_from(Coord[3, 3], [:nw]) { |p| p == :x }
    count4 = b.each_from(Coord[3, 3], [:nw, :s]) { |p| p == :o }
    count5 = b.each_from(Coord[3, 6], [:nw, :s, :e, :w]) { |p| !p.nil? }

    assert_equal(4, count1)
    assert_equal(1, count2)
    assert_equal(0, count3)
    assert_equal(3, count4)
    assert_equal(0, count5)
  end

  def test_move
    b = Board.square(3)

    assert_equal(:x, b[0, 0] = :x)
    assert_equal(:o, b[2, 2] = :o)
    assert_nil(b[1, 1])

    assert_equal(b, b.move([0, 0], [1, 1]))

    assert_nil(b[0, 0])
    assert_equal(:o, b[2, 2])
    assert_equal(:x, b[1, 1])

    assert_equal(b, b.move([2, 2], [1, 1]))

    assert_nil(b[0, 0])
    assert_nil(b[2, 2])
    assert_equal(:o, b[1, 1])
  end

  def test_clear
    b = Board.square(4)
    assert_equal(16, b.empty_count)
    assert_equal(:black, b[:a1, :a2, :a3] = :black)
    assert_equal(:white, b[:b1, :b2, :b3, :b4] = :white)
    assert_equal(9, b.empty_count)
    assert_equal(16, b.clear.empty_count)
  end

  def test_fill
    b = Board.square(4)
    assert_equal(16, b.empty_count)
    b.fill(:black)
    assert_equal(0, b.empty_count)
    assert_equal(16, b.count(:black))
    b.fill(:white)
    assert_equal(0, b.empty_count)
    assert_equal(0, b.count(:black))
    assert_equal(16, b.count(:white))
  end

  def test_to_s
    b = Board.square(2)
    b[0, 0] = '0'
    b[1, 0] = '1'
    b[0, 1] = '2'
    b[1, 1] = '3'

    assert_equal(" ab\n1011\n2232\n ab\n", b.to_s)

    b = Board.rect(2, 10)
    b[0, 0], b[1, 0], b[0, 9], b[1, 9] = 'a', 'b', 'c', 'd'
    s = <<~EOF
        ab
       1ab1
       2  2
       3  3
       4  4
       5  5
       6  6
       7  7
       8  8
       9  9
      10cd10
        ab
    EOF

    assert_equal(s, b.to_s)
  end

  def test_find_plugin
    plugin = Board::Plugins::Frontier

    assert_equal(plugin, Board.find_plugin(plugin))
    assert_equal(plugin, Board.find_plugin('frontier'))
    assert_equal(plugin, Board.find_plugin(:frontier))

    plugin = Board::Plugins::CustodialFlip

    assert_equal(plugin, Board.find_plugin(plugin))
    assert_equal(plugin, Board.find_plugin('custodial_flip'))
    assert_equal(plugin, Board.find_plugin(:custodial_flip))

    assert_nil(Board.find_plugin(nil))
    assert_nil(Board.find_plugin('nonexistant_plugin'))
    assert_nil(Board.find_plugin(:nonexistant_plugin))
  end

  def test_init_plugin
    b = Board.square(4, plugins: [:frontier, :in_a_row])

    assert((class << b; ancestors; end).include?(Board::Plugins::Frontier))
    assert_equal([], b.frontier)

    assert((class << b; ancestors; end).include?(Board::Plugins::InARow))
    assert_equal([], b.threats)
    assert_nil(b.window_size)
  end

  def test_triangle_cells
    b = Board.square(5, cell_shape: :triangle)
    assert_equal(:triangle, b.cell_shape)

    assert_raises(RuntimeError) { b.directions }
    b.directions(:a1)

    assert_raises(RuntimeError) do
      Board.square(5, cell_shape: :triangle,
                       directions: [:n, :e, :w, :s])
    end

    assert_equal([:w, :e, :s], b.directions(:a1))
    assert_equal([:n, :e, :w], b.directions(:b1))
    assert_equal([:w, :e, :s], b.directions(:c1))
    assert_equal([:n, :e, :w], b.directions(:d1))
    assert_equal([:w, :e, :s], b.directions(:e1))

    assert_equal([:n, :e, :w], b.directions(:a2))
    assert_equal([:w, :e, :s], b.directions(:b2))
    assert_equal([:n, :e, :w], b.directions(:c2))
    assert_equal([:w, :e, :s], b.directions(:d2))
    assert_equal([:n, :e, :w], b.directions(:e2))

    assert_equal([:w, :e, :s], b.directions(:a3))
    assert_equal([:n, :e, :w], b.directions(:b3))
    assert_equal([:w, :e, :s], b.directions(:c3))
    assert_equal([:n, :e, :w], b.directions(:d3))
    assert_equal([:w, :e, :s], b.directions(:e3))

    assert_equal(%w(a2 b1),
                  b.coords.neighbors(Coord[:a1]).map(&:to_s).sort)
    assert_equal(%w(a1 c1),
                  b.coords.neighbors(Coord[:b1]).map(&:to_s).sort)
    assert_equal(%w(b2 c1 d2),
                  b.coords.neighbors(Coord[:c2]).map(&:to_s).sort)
    assert_equal(%w(a2 b3 c2),
                  b.coords.neighbors(Coord[:b2]).map(&:to_s).sort)
  end

  def test_group_by_connectivity
    b = Board.square 3

    b[:a1, :b3, :c3] = :x

    groups = b.group_by_connectivity(b.occupied(:x))

    assert_equal(2, groups.length)
    assert(groups.include?([Coord[:a1]]))
    assert(groups.include?([Coord[:b3], Coord[:c3]]))

    b[:b2] = :x

    groups = b.group_by_connectivity(b.occupied(:x))

    assert_equal(1, groups.length)
    assert_equal([Coord[:a1], Coord[:b2], Coord[:b3], Coord[:c3]].sort,
                  groups.first.sort)

    b[:b2] = :o

    groups = b.group_by_connectivity(b.occupied(:x))

    assert_equal(2, groups.length)
    assert(groups.include?([Coord[:a1]]))
    assert(groups.include?([Coord[:b3], Coord[:c3]]))
  end

  def test_path
    b = Board.square 3

    b[:a1, :b3, :c3] = :x

    assert(!b.path?(Coord[:a1], Coord[:c3]))

    b[:b2] = :x

    assert(b.path?(Coord[:a1], Coord[:c3]))

    b[:b2] = :o

    assert(!b.path?(Coord[:a1], Coord[:c3]))

    b[:c2] = :x

    assert(!b.path?(Coord[:a1], Coord[:c3]))

    b[:c1] = :x

    assert(!b.path?(Coord[:a1], Coord[:c3]))

    b[:b1] = :x

    assert(b.path?(Coord[:a1], Coord[:c3]))
  end

end
