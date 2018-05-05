# frozen_string_literal: true

# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

# Coords is a collection of Coord objects.  Coords can be thought of as a
# part of a given Board.
#
# For example:
#
#   Board.square( 3 ).coords
#     # => #<Coords @width=3, @height=3, @omitted=[],
#                   @coords=[a1, b1, c1, a2, b2, c2, a3, b3, c3],
#                   @bounds=[a1, c3]>
#
# Coords is an immutable collection, which allows more than one mutable Board
# to share the same set of Coords.
#

class Coords
  include Enumerable
  extend Memoizable

  class << self
    extend Memoizable
    memoize :new
  end

  attr_reader :bounds, :width, :height, :coords, :omitted, :cell_shape,
    :opts
  protected :coords

  DIRECTIONS = { n: Coord.new(0, -1),  s: Coord.new(0, 1),
                 w: Coord.new(-1, 0),  e: Coord.new(1, 0),
                 nw: Coord.new(-1, -1), ne: Coord.new(1, -1),
                 sw: Coord.new(-1, 1),  se: Coord.new(1, 1) }.freeze

  UP_DIRECTIONS   = [:w, :e, :s]
  DOWN_DIRECTIONS = [:n, :e, :w]

  # Creates a new Coords collection.  You shouldn't need to use this method,
  # Coords get created automatically when Board's are instantiated.  This
  # method is memoized.

  def initialize(bounds, opts={})
    @bounds  = canonical_bounds(bounds)
    @width   = (bounds.first.x - bounds.last.x).abs + 1
    @height  = (bounds.first.y - bounds.last.y).abs + 1

    @opts = opts
    @omitted = (opts[:omit] || []).dup.freeze

    @cell_shape = opts[:cell_shape]
    @directions = opts[:directions] || [:n, :e, :w, :s, :ne, :nw, :se, :sw]

    @coords = []

    ((bounds.first.y)..(bounds.last.y)).each do |y|
      ((bounds.first.x)..(bounds.last.x)).each do |x|
        c = Coord.new(x, y)
        @coords << c unless omitted.include?(c)
      end
    end
  end

  # Coords are immutable so dup returns self.

  def dup # :nodoc:
    self
  end

  # Returns true if this set of Coords contains the given Coord.  This takes
  # into account bounds and the list of omitted Coord's.  For an infinite
  # Board this only returns true if the Coords *currently* include the given
  # Coord.  Obviously, an infinite board would include any Coord.  Coords is
  # finite and immutable so an infinite Board's Coords object is replaced each
  # time the Board grows.

  def include?(c)
    bs = bounds
    if c.x < bs.first.x || c.x > bs.last.x ||
       c.y < bs.first.y || c.y > bs.last.y
      return nil
    end

    return true if omitted.empty?

    if omitted.length < coords.length
      !omitted.include?(c)
    else
      coords.include?(c)
    end
  end

  # Returns the next Coord in the given direction (d) from the given Coord (c).
  # This is like Coord#next but returns nil if the next coord is not a member
  # of this Coords set.  This does *not* skip over omitted Coord's.

  def next(c, d)
    nc = c + DIRECTIONS[d]
    include?(nc) ? nc : nil
  end

  # Iterate over each Coord in this set.

  def each
    coords.each { |c| yield c }
  end

  # Return an array of the Coord's in this set.

  def to_a
    coords
  end

  # Return the number of Coord's in this set.

  def length
    coords.length
  end

  # Only dumps the bounds and omitted list.

  def _dump(depth=-1) # :nodoc:
    Marshal.dump([bounds, opts])
  end

  # Reconstruct the Coords object in the marshal string.  This is cached and
  # will not create a dup object.

  def self._load(str) # :nodoc:
    bounds, opts = *Marshal.load(str)
    opts.empty? ? new(bounds) : new(bounds, opts)
  end

  # Hash this Coords object.

  def hash
    [width, height].hash
  end

  # Group the Coords in the set by the property specified in the block.
  #
  # Example:
  #
  #   Board.square( 3 ).coords.group_by { |c| c.x }
  #     # => [[a1, a2, a3], [b1, b2, b3], [c1, c2, c3]]
  #
  #   Board.square( 3 ).coords.group_by { |c| c.y }
  #     # => [[a1, b1, c1], [a2, b2, c2], [a3, b3, c3]]
  #

  def group_by
    r, a = {}, []
    each do |c|
      y = yield c
      r[y] ||= a.size
      (a[r[y]] ||= []) << c
    end
    a
  end

  # Return the Coord's in the row indicated by the given Coord.
  #
  # Example:
  #
  #   Board.square( 3 ).coords.row( Coord[:a2] )
  #     # => [a2, b2, c2]
  #

  def row(coord)
    coords.select { |c| coord.y == c.y }
  end

  # Return the Coord's in the column indicated by the given Coord.
  #
  # Example:
  #
  #   Board.square( 3 ).coords.column( Coord[:a2] )
  #     # => [a1, a2, a3]
  #

  def column(coord)
    coords.select { |c| coord.x == c.x }
  end

  # Return the Coord's on the diagonal indicated by the given Coord.  The
  # second parameter, slope, should be 1 or -1 to indicate which diagonal
  # you want.  The default slope is 1.
  #
  # Example:
  #
  #   Board.square( 3 ).coords.diagonal( Coord[:b2], 1 )
  #     # => [a1, b2, c3]
  #
  #   Board.square( 3 ).coords.diagonal( Coord[:b2], -1 )
  #     # => [c1, b2, a3]
  #

  def diagonal(coord, slope=1)
    coords.select { |c| slope * (coord.y - c.y) == (coord.x - c.x) }
  end

  # Get the connectivity directions for the given Coord.  Note:  For most
  # boards this is a constant list so you don't have to provide a Coord.
  # However, if the cells are :triangle shaped, you *must* provide a Coord
  # or an exception will be raised.

  def directions(coord=nil)
    return @directions unless cell_shape == :triangle

    if coord.nil?
      raise 'Coords#directions requires a Coord when cell_shape is :triangle'
    end

    if coord.y.even?
      coord.x.even? ? UP_DIRECTIONS : DOWN_DIRECTIONS
    else
      coord.x.even? ? DOWN_DIRECTIONS : UP_DIRECTIONS
    end
  end

  # Like #neighbors but returns nil for Coord's that aren't a part of this
  # Coords set.

  def neighbors_nil(coord, directions=directions(coord))
    a = directions.map { |dir| coord + DIRECTIONS[dir] }
    a.map { |c| !include?(c) ? nil : c }
  end

  # Returns the neighbors of the given Coord in the given directions.  You
  # should probably not specify the list of directions with each call.
  #
  # Example:
  #
  #   b = Board.square( 3, :directions => [:n, :e, :w, :s] )
  #
  #   b.coords.neighbors( Coord[:a1] )              # => [b1, a2]
  #   b.coords.neighbors( Coord[:a1], [:e, :w] )    # => [b1]
  #
  # Notice how the default is set on a per Board basis with the :directions
  # parameter.  With this approach you should almost never need to provide
  # the directions parameter.  However, you can still override the default
  # if necessary.

  def neighbors(coord, directions=directions(coord))
    a = directions.map { |dir| coord + DIRECTIONS[dir] }
    a.select! { |c| include?(c) }
    a
  end

  # Returns a "ring" of Coord's around the given coord.  The distance (d)
  # defines how large the ring is.  You should not need to provide a shape
  # or directions array.  These are taken from the Board via CoordsProxy.
  #
  # Note:  A distance of 0 returns the given Coord itself.  A distance of
  # 1 is equivalent to calling #neighbors.
  #
  # This method only includes those Coord's at distance d from the given
  # Coord (not, for example, less than d), so there will be no overlap between
  # rings.
  #
  # Example:
  #
  #   b = Board.square( 5 )
  #
  #   b.coords.ring( Coord[:c3], 0 )
  #     # => [c3]
  #
  #   b.coords.ring( Coord[:c3], 1 )
  #     # => [c2, d3, b3, c4, d2, b2, d4, b4]
  #
  #   b.coords.ring( Coord[:c3], 2 )
  #     # => [a1, b1, c1, d1, e1, a2, e2, a3, e3, a4, e4, a5, b5, c5, d5, e5]
  #

  def ring(coord, d, shape=cell_shape, directions=directions(coord))
    return coord if d == 0
    return neighbors(coord, directions) if d == 1

    case shape
      when :square

        coords.select do |c|
          dx = (c.x - coord.x).abs
          dy = (c.y - coord.y).abs

          (dx == d && dy <= d) || (dx <= d && dy == d)
        end

      when :hexagon

        dc = Coord[d - coord.x, d - coord.y]

        d2 = d * 2
        d1 = d + 1

        coords.select do |c|
          c2 = c + dc

          !(c2.x < 0 || c2.y < 0 ||
             c2.x > d2 || c2.y > d2 ||
             (c2.x - c2.y).abs >= d1) &&
          (c2.x == 0        || c2.y == 0  ||
           c2.x == d2       || c2.y == d2 ||
           c2.x - c2.y == d || c2.y - c2.x == d)
        end

    end
  end

  # Are the given coords all connected?  This checks that the list of coords
  # are connected (in terms of Board#directions and Coords#include?).
  def connected?(cs)
    cs = cs.dup
    check = [cs.first]

    while c = check.pop
      cs.delete(c)

      neighbors(c).each do |nc|
        check << nc  if cs.include?(nc)
      end
    end

    cs.empty?
  end

  # Note:  Coords#to_s is oddly unhelpful.  I guess I never use it...

  def to_s
    inject('') { |s, c| s + c.to_s }
  end

  # Returns the bounds for a given width and height.  This assumes the origin
  # is (0,0).

  def self.bounds_for(width, height)
    [Coord[0, 0], Coord[width - 1, height - 1]]
  end

  memoize :row
  memoize :column
  memoize :diagonal
  memoize :neighbors
  memoize :neighbors_nil
  memoize :ring

  private

  # Transform the given bounds into "canonical bounds", that is the first
  # coord has the min x and y's and the last the max x and y's.  This prevents
  # memoization trouble.

  def canonical_bounds(bounds)
    xs = bounds.first.x, bounds.last.x
    ys = bounds.first.y, bounds.last.y

    [Coord[xs.min, ys.min], Coord[xs.max, ys.max]]
  end
end
