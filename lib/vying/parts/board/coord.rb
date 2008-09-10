# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

class Array

  # Returns the first element in this Array.  This only really make sense with
  # an array that looks something like this:
  #
  #   [1,2].x => 1
  #

  def x
    self[0] if length == 2 && self[0].class == Fixnum
  end

  # Returns the second element in this Array.  This only really make sense with
  # an array that looks something like this:
  #
  #   [1,2].y => 2
  #

  def y
    self[1] if length == 2 && self[1].class == Fixnum
  end
end

class String

  # Returns the x coordinate of a string that's formated as "[a-z][1-9]+", 
  # for example:
  #
  #   "b1".x => 1
  #
  # Note that "a1" is equivalent to (0,0).

  def x
    self.ord - 97 if y
  end

  # Returns the y coordinate of a string that's formated as "[a-z][1-9]+", 
  # for example:
  #
  #   "b1".y => 0
  #
  # Note that "a1" is equivalent to (0,0).

  def y
    $1.to_i-1 if self =~ /^\w(\d+)$/
  end

  # If this string represents multipe coordinates in the form "([a-z][1-9]+)*",
  # they are parsed out and returned as an array of Coord's.

  def to_coords
    scan( /[a-z]\d+/ ).map { |s| Coord[s] }
  end
end

class Symbol

  # Returns the x coordinate of a symbol that's formated as "[a-z][1-9]+", 
  # for example:
  #
  #   :b1.x => 1
  #
  # Note that :a1 is equivalent to (0,0).

  def x
    to_s.x
  end

  # Returns the y coordinate of a symbol that's formated as "[a-z][1-9]+", 
  # for example:
  #
  #   :b1.y => 0
  #
  # Note that :a1 is equivalent to (0,0).

  def y
    to_s.y
  end

  # If this symbol represents multipe coordinates in the form "([a-z][1-9]+)*",
  # they are parsed out and returned as an array of Coord's.

  def to_coords
    to_s.scan( /[a-z]\d+/ ).map { |s| Coord[s] }
  end
end

class Coord
  extend Memoizable

  class << self
    extend Memoizable
    memoize :new
  end

  @@coords_cache = {}

  attr_reader :x, :y

  # Create a new Coord with the given (x,y) coordinates.

  def initialize( x, y )
    @x, @y = x, y
    @s = to_s
  end

  def dup
    self
  end

  def _dump( depth=-1 )
    to_s
  end

  def self._load( str )
    Coord[str]
  end

  def <=>( c )
    (t = y <=> c.y) != 0 ? t : x <=> c.x
  end

  def to_s
    @s || "#{(97+x).chr}#{y+1}"
  end

  def to_sym
    to_s.intern
  end

  def inspect
    to_s
  end

  def to_coords
    [self]
  end

  def next( d )
    return Coord[x+1,y] if d == :e
    return Coord[x-1,y] if d == :w
    return Coord[x,y-1] if d == :n
    return Coord[x,y+1] if d == :s
    return Coord[x+1,y-1] if d == :ne
    return Coord[x+1,y+1] if d == :se
    return Coord[x-1,y-1] if d == :nw
    return Coord[x-1,y+1] if d == :sw
    nil
  end

  # Hash on the Coord's #x and #y values.

  def hash
    [x, y].hash
  end

  # Two coords are considered equal if both x and y are equal.  This comparison
  # uses duck typing such that a Coord can be compared to any object that
  # responds to #x and #y methods.  (Such as String, Symbol, and Array).

  def ==( o )
    o.respond_to?( :x ) && o.respond_to?( :y ) &&
    x == o.x && y == o.y
  end

  # See Coord#==.

  def eql?( o )
    self == o
  end

  def self.expand( coords )
    d = coords.first.direction_to( coords.last )
    return coords unless d

    expanded = [coords.first]
    c1 = coords.first.next( d )
    until c1 == coords.last
      expanded << c1
      c1 = c1.next( d )
    end

    expanded << coords.last

    expanded
  end
end

