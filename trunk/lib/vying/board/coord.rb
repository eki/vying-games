require 'vying/board/boardext'
require 'vying/memoize'

class Array
  def x
    self[0]
  end

  def y
    self[1]
  end
end

class String
  def x
    self[0]-97
  end

  def y
    self =~ /\w(\d+)$/
    $1.to_i-1
  end

  def to_coords
    scan( /[a-z]\d+/ ).map { |s| Coord[s] }
  end
end

class Symbol
  def x
    to_s[0]-97
  end

  def y
    to_s =~ /\w(\d+)$/
    $1.to_i-1
  end

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

  attr_reader :x, :y

  def dup
    self
  end

  def copy
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

