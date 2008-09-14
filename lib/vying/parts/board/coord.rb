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

  # Returns the x coordinate of a string that's formated as "[a-z][1-9]+" or
  # "(x,y)" where x and y are positive or negative integers.
  #
  # For example:
  #
  #   "b1".x      => 1
  #   "(-1,6)".x  => -1
  #
  # Note that "a1" is equivalent to (0,0).

  def x
    if self =~ /^\((-{0,1}\d+),-{0,1}\d+\)$/
      $1.to_i
    elsif self =~ /^(\w)\d+$/
      $1.ord - 97
    end
  end

  # Returns the y coordinate of a string that's formated as "[a-z][1-9]+" or
  # "(x,y)" where x and y are positive or negative integers.
  #
  # For example:
  #
  #   "b1".y      => 0
  #   "(-1,6)".y  => 6
  #
  # Note that "a1" is equivalent to (0,0).

  def y
    if self =~ /^\(-{0,1}\d+,(-{0,1}\d+)\)$/
      $1.to_i
    elsif self =~ /^\w(\d+)$/
      $1.to_i-1
    end
  end

  # If this string represents multipe coordinates in the form "([a-z][1-9]+)*"
  # or "((x,y))*" they are parsed out and returned as an array of Coord's.
  # The two "styles" of coords can be intermixed.
  #
  # For example:
  #
  #   "a1b3(0,-1)".to_coords  => [Coord[0,0], Coord[1,2], Coord[0,-1]]
  #

  def to_coords
    scan( /(?:[a-z]\d+)|(?:\(-{0,1}\d+,-{0,1}\d+\))/ ).map { |s| Coord[s] }
  end
end

class Symbol

  # Returns the x coordinate of a symbol by first converting to a String
  # and then calling String#x.

  def x
    to_s.x
  end

  # Returns the y coordinate of a symbol by first converting to a String
  # and then calling String#y.

  def y
    to_s.y
  end

  # Returns an array of Coord objects parsed by converting the symbol to
  # a String and then calling String#to_coords.

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

  # Create a new Coord with the given (x,y) coordinates.

  def initialize( x, y )
    @x, @y = x, y
    @s_chess = to_s( true  )
    @s       = to_s( false )
  end

  @@coords_cache = {}

  def self.[]( *args )
    if args.length == 2 && args.first.class == Fixnum &&
                           args.last.class  == Fixnum

      return Coord.new( args.first, args.last )

    elsif args.length == 1
      return args.first if args.first.class == Coord

      c = @@coords_cache[args.first]

      unless c
        x, y = args.first.x, args.first.y

        return nil if x.nil? || y.nil?

        c = new( x, y )
        @@coords_cache[args.first] = c
      end
 
      return c

    else
      return args.map do |arg|
        if arg.class == Coord
          arg
        else
          c = @@coords_cache[arg]

          unless c
            x, y = arg.x, arg.y

            c = !x || !y  ? nil : new( x, y )
            @@coords_cache[arg] = c
          end

          c
        end
      end     
    end

    return nil
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

  def +( o )
    Coord.new( x + o.x, y + o.y )
  end

  def <=>( c )
    (t = y <=> c.y) != 0 ? t : x <=> c.x
  end

  def to_s( chess=true )
    return @s_chess if chess && @s_chess
    return @s       if chess && @s

    if chess && x >= 0 && x < 26 && y >= 0
      "#{(97+x).chr}#{y+1}"
    else
      "(#{x},#{y})"
    end
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

  def direction_to( o )
    dx, dy = x - o.x, y - o.y

    if dx == 0
      if dy > 0
        return :n
      elsif dy < 0
        return :s
      end
    elsif dy == 0
      if dx > 0
        return :w
      elsif dx < 0
        return :e
      end
    elsif dx == dy
      if dx < 0 && dy < 0
        return :se
      elsif dx > 0 && dy > 0
        return :nw
      end
    elsif -dx == dy
      if dx > 0 && dy < 0
        return :sw
      elsif dx < 0 && dy > 0
        return :ne
      end
    end

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

