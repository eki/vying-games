require 'vying/memoize'
require 'vying/board/boardext'

class Array
  alias_method :old_comp, :"<=>"

  def x
    self[0]
  end

  def y
    self[1]
  end

  def add!( c )
    self[0] += c.x
    self[1] += c.y
    self
  end

  def add( c )
    [x,y].add!( c )
  end

  def <=>( c )
    return old_comp( c ) unless c.is_coord? && self.is_coord?
    (t = y <=> c.y) != 0 ? t : x <=> c.x
  end

  def is_coord?
    length == 2 && x.kind_of?( Fixnum ) && y.kind_of?( Fixnum )
  end

  def direction_to( c )
    dx = x - c.x
    dy = y - c.y

    if dx == 0
      return :n  if dy > 0
      return :s  if dy < 0
    elsif dy == 0
      return :w  if dx > 0
      return :e  if dx < 0
    elsif dx == dy
      return :nw if dx > 0 && dy > 0
      return :se if dx < 0 && dy < 0
    elsif -dx == dy
      return :ne if dx < 0 && dy > 0
      return :sw if dx > 0 && dy < 0
    end
  end

  def to_sym
    "#{(97+x).chr}#{y+1}".to_sym
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
end

class Symbol
  def x
    to_s[0]-97
  end

  def y
    to_s =~ /\w(\d+)$/
    $1.to_i-1
  end
end

#class Coord
#  def Coord.new( x, y )
#    [x,y]
#  end
#
#  def Coord.[]( *a )
#    if a.length == 2 && a.all? { |o| o.kind_of? Fixnum }
#      a
#    else
#      ps = a.map { |o| [o.x, o.y] }
#      ps.length == 1 ? ps.first : ps                           
#    end
#  end
#end

class Coord
  attr_reader :x, :y

#  def initialize( x, y )
#    @x, @y = x, y
#  end

  
#  class << self
#    def []( *a )
#      if a.length == 2 && a.all? { |o| o.kind_of? Fixnum }
#        Coord.new( a.x, a.y )
#      else
#        ps = a.map { |o| Coord.new( o.x, o.y ) }
#        ps.length == 1 ? ps.first : ps                           
#      end
#    end
#
#    extend Memoizable
#    memoize :new
#    memoize :[]
#  end
#
#  def ==( c )
#    c.respond_to?( :x ) && c.respond_to?( :y ) && 
#    self.x == c.x && self.y == c.y
#  end
#
#  def eql?( c )
#    self == c
#  end
#
#  def hash
#    [x,y].hash
#  end

  def <=>( c )
    (t = y <=> c.y) != 0 ? t : x <=> c.x
  end

#  def +( c )
#    Coord.new( x+c.x, y+c.y )
#  end
#
#  def direction_to( c )
#    dx = x - c.x
#    dy = y - c.y
#
#    return :n  if dx == 0 && dy > 0
#    return :s  if dx == 0 && dy < 0
#    return :w  if dy == 0 && dx > 0
#    return :e  if dy == 0 && dx < 0
#
#    return :ne if dx < 0 && dy > 0 && -dx == dy
#    return :nw if dx > 0 && dy > 0 &&  dx == dy
#    return :se if dx < 0 && dy < 0 &&  dx == dy
#    return :sw if dx > 0 && dy < 0 && -dx == dy
#  end

  def to_s
    "#{(97+x).chr}#{y+1}"
  end

  def inspect
    to_s
  end
end

#class Coords
#  include Enumerable
#  extend Memoizable
#
#  class << self
#    extend Memoizable
#    memoize :new
#  end
#
#  attr_reader :width, :height, :coords
#  protected :coords
#
#  DIRECTIONS = { :n  => [0, -1],  :s  => [0, 1],
#                 :w  => [-1, 0],  :e  => [1, 0],
#                 :nw => [-1, -1], :ne => [1, -1],
#                 :sw => [-1, 1],  :se => [1, 1] }
#
#  def initialize( w, h )
#    @width = w
#    @height = h
#    @coords = Array.new( w*h ) { |i| [i%w, i/w] } 
#  end
#
#  def each
#    coords.each { |c| yield c }
#  end
#
#  def include?( c )
#    c.x >= 0 && c.x < width && c.y >= 0 && c.y < height
#  end
#
#  def hash
#    [width, height].hash
#  end
#
#  def group_by
#    r, a = {}, []
#    each do |c|
#      y = yield c
#      r[y] ||= a.size
#      (a[r[y]] ||= []) << c
#    end
#    a
#  end
#
#  def row( coord )
#    coords.select { |c| coord.y == c.y }
#  end
#
#  def rows
#    column( Coord[0,0] ).map { |c| row( c ) }
#  end
#
#  def column( coord )
#    coords.select { |c| coord.x == c.x }
#  end
#
#  def columns
#    row( Coord[0,0] ).map { |c| column( c ) }
#  end
#
#  def diagonal( coord, slope=1 )
#    coords.select { |c| slope*(coord.y-c.y) == (coord.x-c.x) }
#  end
#
#  def diagonals( slope=1 )
#    cs = row( Coord[0,0] )
#    cs += column( slope == 1 ? Coord[0,0] : Coord[width-1,0] )
#    cs.uniq.map { |c| diagonal( c, slope ) }
#  end
#
#  def neighbors_nil( coord, directions=[:n,:ne,:e,:se,:s,:sw,:w,:nw] )
#    a = directions.map { |dir| coord.add( DIRECTIONS[dir] ) }
#    a.map { |c| (! include?( c )) ? nil : c }
#  end
#
#  def neighbors( coord, directions=[:n,:ne,:e,:se,:s,:sw,:w,:nw] )
#    a = directions.map { |dir| coord.add( DIRECTIONS[dir] ) }
#    a.reject! { |c| ! include?( c ) }
#    a
#  end
#
#  def next( coord, direction )
#    include?( n = coord.add( DIRECTIONS[direction] ) ) ? n : nil
#  end
#
#  def radius( coord, r )
#    directions=[:n,:ne,:e,:se,:s,:sw,:w,:nw]
#    a = directions.map do |dir|
#      sa, c, i = [], coord, 0
#      while (c = self.next( c, dir )) && i < r
#        sa << c
#        i += 1
#      end
#      sa
#    end 
#    a.flatten!
#    a.reject! { |c| ! include?( c ) }
#    a
#  end
#
#  def to_s
#    inject( '' ) { |s,c| s + "#{c.to_sym}" }
#  end
#
#  memoize :row
#  memoize :column
#  memoize :diagonal
#  memoize :neighbors
#  memoize :neighbors_nil
#end

class Coords
  include Enumerable
  extend Memoizable

  class << self
    extend Memoizable
    memoize :new
  end

  attr_reader :width, :height, :coords
  protected :coords

  DIRECTIONS = { :n  => Coord.new( 0, -1 ),  :s  => Coord.new( 0, 1 ),
                 :w  => Coord.new( -1, 0 ),  :e  => Coord.new( 1, 0 ),
                 :nw => Coord.new( -1, -1 ), :ne => Coord.new( 1, -1 ),
                 :sw => Coord.new( -1, 1 ),  :se => Coord.new( 1, 1 ) }

  def initialize( w, h )
    @width = w
    @height = h
    @coords = Array.new( w*h ) { |i| Coord.new( i%w, i/w ) } 
  end

  def each
    coords.each { |c| yield c }
  end

  def include?( c )
    c.x >= 0 && c.x < width && c.y >= 0 && c.y < height
  end

  def hash
    [width, height].hash
  end

  def group_by
    r, a = {}, []
    each do |c|
      y = yield c
      r[y] ||= a.size
      (a[r[y]] ||= []) << c
    end
    a
  end

  def row( coord )
    coords.select { |c| coord.y == c.y }
  end

  def rows
    column( Coord[0,0] ).map { |c| row( c ) }
  end

  def column( coord )
    coords.select { |c| coord.x == c.x }
  end

  def columns
    row( Coord[0,0] ).map { |c| column( c ) }
  end

  def diagonal( coord, slope=1 )
    coords.select { |c| slope*(coord.y-c.y) == (coord.x-c.x) }
  end

  def diagonals( slope=1 )
    cs = row( Coord[0,0] )
    cs += column( slope == 1 ? Coord[0,0] : Coord[width-1,0] )
    cs.uniq.map { |c| diagonal( c, slope ) }
  end

  def neighbors_nil( coord, directions=[:n,:ne,:e,:se,:s,:sw,:w,:nw] )
    a = directions.map { |dir| coord + DIRECTIONS[dir] }
    a.map { |c| (! include?( c )) ? nil : c }
  end

  def neighbors( coord, directions=[:n,:ne,:e,:se,:s,:sw,:w,:nw] )
    a = directions.map { |dir| coord + DIRECTIONS[dir] }
    a.reject! { |c| ! include?( c ) }
    a
  end

  def next( coord, direction )
    include?( n = coord + DIRECTIONS[direction] ) ? n : nil
  end

  def radius( coord, r )
    directions=[:n,:ne,:e,:se,:s,:sw,:w,:nw]
    a = directions.map do |dir|
      sa, c, i = [], coord, 0
      while (c = self.next( c, dir )) && i < r
        sa << c
        i += 1
      end
      sa
    end 
    a.flatten!
    a.reject! { |c| ! include?( c ) }
    a
  end

  def to_s
    inject( '' ) { |s,c| s + "#{c}" }
  end

  memoize :row
  memoize :column
  memoize :diagonal
  memoize :neighbors
  memoize :neighbors_nil
end

