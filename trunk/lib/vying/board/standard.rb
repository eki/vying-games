require 'vying/memoize'

class Coord
  attr_reader :x, :y

  def initialize( x, y )
    @x, @y = x, y
  end

  def Coord.[]( *args )
    if args.length == 2
      return Coord.new( args.first, args.last )
    elsif args.length == 1
      args.first.to_s.downcase =~ /(\w)(\d+)/
      return Coord.new( $1[0]-97, $2.to_i-1 )
    end
  end

  class << self
    extend Memoizable
    memoize :new
    memoize :[]
  end

  def ==( c )
    self.x == c.x && self.y == c.y
  end

  def eql?( c )
    self == c
  end

  def hash
    [x,y].hash
  end

  def <=>( c )
    (t = y <=> c.y) != 0 ? t : x <=> c.x
  end

  def +( c )
    Coord.new( x+c.x, y+c.y )
  end

  def direction_to( c )
    dx = x - c.x
    dy = y - c.y

    return :n  if dx == 0 && dy > 0
    return :s  if dx == 0 && dy < 0
    return :w  if dy == 0 && dx > 0
    return :e  if dy == 0 && dx < 0

    return :ne if dx < 0 && dy > 0 && -dx == dy
    return :nw if dx > 0 && dy > 0 &&  dx == dy
    return :se if dx < 0 && dy < 0 &&  dx == dy
    return :sw if dx > 0 && dy < 0 && -dx == dy
  end

  def to_s
    "#{(97+x).chr}#{y+1}"
  end

  def inspect
    to_s
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

  def ==( o )
    o.respond_to?( :board ) && o.respond_to?( :coords ) &&
    board == o.board && coords == o.coords
  end

  def each
    coords.each { |c| yield self[c] }
    self
  end

  #  Yields the piece at each coordinate starting at 's' in the given
  #  directions.  If the given block returns true, we continue in the
  #  current direction, if the block returns false we move on to the
  #  next direction.  Ultimately the each_from returns a count of the
  #  number of times yield returned true. 

  def each_from( s, directions )
    i = 0
    directions.each do |d|
      c = s
      while (c = coords.next( c, d )) && yield( self[c] )
        i += 1
      end
    end
    i
  end

  def count( piece )
    select { |p| p == piece }.length
  end

  def move( sc, ec )
    self[sc], self[ec] = nil, self[sc]
    self
  end

  def to_s( cs = nil )
    return to_s_coords( cs ) unless cs.nil?


    off = coords.height >= 10 ? 2 : 1
    w = coords.width

    letters = ' '*off + 'abcdefghijklmnopqrstuvwxyz'[0..(w-1)] + ' '*off + "\n"
    coords.column( Coord[0,0] ).inject( letters ) do |s,colc|
      r = coords.row( colc ).inject( '' ) do |rs,c| 
        rs + (self[c].nil? ? ' ' : self[c].to_s[0..0].downcase)
      end
      rh = sprintf( "%*d", off, colc.y+1 )
      re = sprintf( "%*-d", off, colc.y+1 )
      "#{s}#{rh}#{r}#{re}\n" 
    end + letters
  end

  def to_s_coords( coords )
    coords.inject( '' ) do |s,c| 
      "#{s}#{self[c].nil? ? ' ' : self[c].to_s[0..0].downcase}"
    end
  end

  def Board.from_s( pieces, s )
    lines = s.split( "\n" )
    rh = lines.length >= 10 ? 4 : 2
    w, h = lines[0].length-rh, lines.length-2
    b = Board.new( w, h )
    w.times do |i|
      h.times do |j|
        c = lines[j+1][(i+rh/2)..(i+rh/2)]
        pieces.each { |p| b[i,j] = p if c == p.to_s[0..0].downcase }
      end
    end
    b
  end

  def to_html
    s = '<table>'
    rh = '<tr><td><img src="/images/board/empty.png"/></td>'
    h = 'a'
    coords.width.times do
      rh << '<td class="header"><img src="/images/board/letters/'
      rh << h
      rh << '.png"/></td>'
      h.succ!
    end
    rh << '<td><img src="/images/board/empty.png"/></td></tr>'

    s << rh << '</tr>'

    last = nil
    coords.each do |c|
      s << '</tr><tr>'                    if !last.nil? && last.y != c.y

      if c.x == 0
        s << '<td><img src="/images/board/numbers/'
        s << (c.y + 1).to_s
        s << '.png"/></td>'
      end

      s << '<td><img src="/images/board/'
      s << self[c].name.downcase          if self[c].kind_of? Piece
      s << self[c].to_s.downcase          if !self[c].kind_of? Piece
      s << 'empty'                        if self[c].nil?
      s << '.png"/></td>'

      if c.x == coords.width-1
        s << '<td><img src="/images/board/numbers/'
        s << (c.y + 1).to_s
        s << '.png"/></td>'
      end

      last = c
    end

    s << rh << '</table>'
    s
  end
end

