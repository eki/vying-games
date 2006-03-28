require 'memoize'

class Piece
  attr_reader :name, :short

  class << self
    extend Memoizable
    memoize :new
  end

  def initialize( name, short )
    @name, @short = name, short
  end

  def ==( p )
    return nil              if p.nil?
    return short == p.short if p.respond_to? :short
    return to_s == p.to_s  
  end

  def to_s
    short
  end

  def Piece.method_missing( m, *args )
    name = m.to_s
    Piece.new( name.capitalize, name.downcase[0..0] )
  end
end

class Coord
  attr_reader :x, :y

  class << self
    extend Memoizable
    memoize :new
  end

  def initialize( x, y )
    @x, @y = x, y
  end

  def Coord.[]( x, y )
    Coord.new( x, y )
  end

  def <=>( c )
    (t = y <=> c.y) != 0 ? t : x <=> c.x
  end

  def +( c )
    Coord.new( x+c.x, y+c.y )
  end

  def -( c )
    Coord.new( x-c.x, y-c.y )
  end

  def to_s
    #"(#{x},#{y})"
    "#{(97+x).chr}#{y}"
  end
end

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

  def row( coord )
    coords.select { |c| coord.y == c.y }
  end

  def column( coord )
    coords.select { |c| coord.x == c.x }
  end

  def diagonal( coord, slope=1 )
    coords.select { |c| slope*(coord.y-c.y) == (coord.x-c.x) }
  end

  def neighbors( coord, directions=[:n,:ne,:e,:se,:s,:sw,:w,:nw] )
    a = directions.map { |dir| coord + DIRECTIONS[dir] }
    a.reject! { |c| ! include? c }
    a
  end

  def next( coord, direction )
    include?( n = coord + DIRECTIONS[direction] ) ? n : nil
  end

  def line( coord, direction )
    line = []
    while include?( coord = coord + DIRECTIONS[direction] )
      line << coord
    end
    line.empty? ? nil : line
  end

  def to_s
    inject( '' ) { |s,c| s + "#{c}" }
  end

  memoize :row
  memoize :column
  memoize :diagonal
  memoize :neighbors
end

class Board
  include Enumerable

  attr_reader :coords, :board
  protected :board

  def initialize( w=8, h=8 )
    @coords = Coords.new( w, h )
    @board = {}
  end

  def initialize_copy( original )
    @board = original.board.dup
  end

  def []( *c )
    c = *c if c.length == 1
    if c.kind_of? Coord
      @board[c] 
    elsif c.kind_of? Enumerable
      if c.any? { |o| !o.kind_of? Coord }
        @board[Coord.new( *c )]
      else
        c.map { |coord| @board[coord] }
      end
    end
  end

  def []=( *args )
    c,p = args.first( args.length-1 ), args.last
    if c.any? { |o| !o.kind_of? Coord } 
      @board[Coord.new( *c )] = p 
    else
      @board[*c] = p
    end
  end

  def eql?( o )
    self == o
  end

  def ==( o )
    board == o.board && coords == o.coords
  end

  def hash
    @board.hash
  end

  def each
    coords.each { |c| yield self[c] }
    self
  end

  def count( piece )
    select { |p| p == piece }.length
  end

  def to_s( cs = nil )
    if cs.nil?
      return coords.column( Coord[0,0] ).inject( '' ) do |s,colc|
        r = coords.row( colc ).inject( '' ) do |rs,c| 
          rs + (self[c].nil? ? ' ' : self[c].to_s)
        end
        s + r + "\n" 
      end
    else
      return Board.to_s( self[cs] )
    end
  end

  def Board.to_s( pieces )
    s = ''
    pieces.each { |p| s << (p.nil? ? ' ' : p.to_s) }
    s
  end
end

