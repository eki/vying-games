require 'observer'

class Piece
  include Observable

  attr_reader :name, :short

  def initialize( name, short )
    @name, @short = name, short
  end

  EMPTY = Piece.new( 'Empty', ' ' )

  def initialize_copy( piece )
    @name, @short = piece.name, piece.short
  end

  def become( piece )
    piece ||= EMPTY
    changed; notify_observers( self.dup, piece )
    @name, @short = piece.name, piece.short
    self
  end

  def eql?( piece )
    name == piece.name && short == piece.short
  end

  def ==( piece )
    eql?( piece )
  end

  def hash
    short.hash ^ name.hash
  end

  def empty?
    self == EMPTY
  end

  def to_s
    "#{name} (#{short})"
  end

  def Piece.empty
    EMPTY.dup
  end

  def Piece.method_missing( method_id, *args )
    name = method_id.to_s
    Piece.new( name.capitalize, name.downcase[0..0] )
  end
end

class TwoSidedPiece < Piece
  attr_reader :up, :down

  def initialize( up, down )
    @up = up
    @down = down
  end

  def initialize_copy( original )
    @up, @down = original.up.dup, original.down.dup
  end

  def name
    up.name
  end

  def short
    up.short
  end

  def flip
    TwoSidedPiece.new( down.dup, up.dup )
  end

  def flip!
    become( flip )
  end

  def become( piece )
    piece ||= EMPTY
    if piece.class == TwoSidedPiece
      changed; notify_observers( self.dup, piece )
      up.become( piece.up )
      down.become( piece.down )
    elsif piece == down
      flip!
    elsif piece != up && piece != down
      changed; notify_observers( self.dup, piece )
      up.become( piece )
      down.become( piece )
    end
    self
  end

  def eql?( piece )
    up == piece
  end

  def ==( piece )
    eql?( piece )
  end

  def hash
    up.hash
  end

  def empty?
    up.empty?
  end

  def TwoSidedPiece.empty
    TwoSidedPiece.new( Piece.empty, Piece.empty )
  end

  def to_s
    up.to_s
  end
end

class Float
  TOLERANCE = 0.001

  def eql?( f )
    (self-f).abs < TOLERANCE
  end

  def ==( f )
    eql?( f )
  end

  def <=>( f )
    return 0 if self == f
    return 1 if self > f
    return -1 if self < f
  end
end

class Board
  attr_reader :width, :height, :board, :counts, :degree
  attr_writer :degree
  #protected :board, :counts

  SIN = { -360 =>  0.0, -315 =>  0.7, -270 =>  1.0, -225 =>  0.7,
          -180 =>  0.0, -135 => -0.7,  -90 => -1.0,  -45 => -0.7,
             0 =>  0.0,   45 =>  0.7,   90 =>  1.0,  135 =>  0.7,
           180 =>  0.0,  225 => -0.7,  270 => -1.0,  315 => -0.7, 360 =>  0.0 }
  
  COS = { -360 =>  1.0, -315 =>  0.7, -270 =>  0.0, -225 => -0.7,
          -180 => -1.0, -135 => -0.7,  -90 =>  0.0,  -45 =>  0.7,
             0 =>  1.0,   45 =>  0.7,   90 =>  0.0,  135 => -0.7,
           180 => -1.0,  225 => -0.7,  270 =>  0.0,  315 =>  0.7, 360 =>  1.0 }

  @@coords_cache = {}

  def initialize( width=8, height=8, piece=Piece )
    @width = width
    @height = height

    @board = Array.new( width*height ) do
      p = piece.empty; p.add_observer( self ); p
    end

    @degree = 0

    if @@coords_cache[[width,height,0]].nil?
      coords = Array.new( board.length ) { |i| [i%width,i/width] }
      coords.freeze
      @@coords_cache[[width,height,  0]] = coords
      @@coords_cache[[width,height, 45]] = create_coords(  45 )
      @@coords_cache[[width,height, 90]] = create_coords(  90 )
      @@coords_cache[[width,height,135]] = create_coords( 135 )
      @@coords_cache[[width,height,180]] = create_coords( 180 )
      @@coords_cache[[width,height,225]] = create_coords( 225 )
      @@coords_cache[[width,height,270]] = create_coords( 270 )
      @@coords_cache[[width,height,315]] = create_coords( 315 )
    end

    @counts = {piece.empty => board.length}
  end

  def dup
    b = self.class.new( width, height, self[0,0].class )
    b.rotate!( self.degree )
    b.coords.each { |x,y| b[x,y] = self[x,y] unless b[x,y] == self[x,y] }
    b
  end

  def create_coords( deg )
     new_coords = []
     coords.each do |x,y|
       new_coords << Board.rotate( x, y, deg )
     end
     new_coords.sort! do |c1,c2|
       (t = c1[1] <=> c2[1]) != 0 ? t : c1[0] <=> c2[0]
     end
     new_coords.freeze
     new_coords
  end 

  def coords
    @@coords_cache[[width,height,degree%360]]
  end

  def []( x, y )
    @board[xy_to_i(x,y)]
  end

  def []=( x, y, piece )
    @board[xy_to_i(x,y)].become( piece )
  end

  def move( piece, x, y )
    self[x,y] = piece
    piece.become( Piece.empty )
  end

  def update( old, new )
    @counts[old] -= 1
    @counts[new] ||= 0
    @counts[new] += 1
  end

  def xy_to_i( x, y )
    x0,y0 = Board.rotate( x, y, -(degree%360) )
    x0.round+y0.round*width
  end

  def rotate( deg=45 )
    return self if deg == 0
    b = self.dup
    b.rotate!( deg )
  end

  def rotate!( deg=45 )
     @degree += deg
     self
  end

  def Board.rotate( x, y, deg )
    [x*COS[deg]-y*SIN[deg],x*SIN[deg]+y*COS[deg]]
  end

  def neighbors4( x, y )
    a = [[x+1,y],[x-1,y],[x,y+1],[x,y-1]]
    a.select { |c| coords.include?( c ) }
  end

  def neighbors8( x, y )
    a = [[x+1,y],[x-1,y],[x,y+1],[x,y-1],
         [x+1,y+1],[x-1,y+1],[x-1,y-1],[x+1,y-1]]
    a.select { |c| coords.include?( c ) }
  end

  def coords_right_of( x, y )
    coords.select { |x1,y1| y == y1 && x1 > x }
  end

  def capture_set_coords( x, y )
    s = []
    8.times do |i|
      b = self.rotate( i*45 )
      x1, y1 = Board.rotate( x, y, i*45 )
      t = []
      b.coords_right_of( x1, y1 ).each do |x2,y2|
        if b[x2,y2] == Piece.empty
          break
        elsif b[x2,y2] != self[x,y]
          x3, y3 = Board.rotate( x2, y2, -i*45 )
          t << [x3.round,y3.round]
        elsif b[x2,y2] == self[x,y]
          s += t
          break
        end
      end
    end
    s
  end

  def capture_set( x, y )
    capture_set_coords( x, y ).map { |x,y| self[x,y] }
  end

  def capture?( x, y, piece )
    8.times do |i|
      b = self.rotate( i*45 )
      x1, y1 = Board.rotate( x, y, i*45 )
      t = []
      b.coords_right_of( x1, y1 ).each do |x2,y2|
        if b[x2,y2] == Piece.empty
          break
        elsif b[x2,y2] != piece
          x3, y3 = Board.rotate( x2, y2, -i*45 )
          t << [x3.round,y3.round]
        elsif b[x2,y2] == piece
          return true if t.length > 0
          break
        end
      end
    end
    false
  end

  def capture( x, y, piece=nil )
    self[x,y] = piece unless piece.nil?
    capture_set( x, y ).each { |p| yield p }
  end

  def count( piece )
    @counts[piece] || 0
  end

  def eql?( b )
    width == b.width && height == b.height && board == b.board
  end

  def ==( b )
    eql?( b )
  end

  def hash
    height.hash ^ width.hash ^ board.hash
  end

  def to_s
    s, last_y = '', nil
    coords.each do |x,y|
      last_y ||= y
      s << "\n" if last_y != y && last_y = y
      s << self[x,y].short
    end
    s
  end

  def Board.xy_to_s( x, y )
    "#{(97+x).chr}#{y}"
  end

  def =~( pattern )
    to_s =~ pattern
  end

end

