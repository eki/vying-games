
class Piece
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
    @name, @short = piece.name, piece.short
  end

  def eql?( piece )
    name == piece.name && short == piece.short
  end

  def ==( piece )
    eql?( piece )
  end

  def hash
    19 + short.hash * 37 +
         name.hash  * 37
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

  attr_reader :width, :height, :coords, :board, :counts, :degree
  protected :board, :counts

  SIN = { -360 =>  0.0, -315 =>  0.7, -270 =>  1.0, -225 =>  0.7,
          -180 =>  0.0, -135 => -0.7,  -90 => -1.0,  -45 => -0.7,
             0 =>  0.0,   45 =>  0.7,   90 =>  1.0,  135 =>  0.7,
           180 =>  0.0,  225 => -0.7,  270 => -1.0,  315 => -0.7, 360 =>  0.0 }
  
  COS = { -360 =>  1.0, -315 =>  0.7, -270 =>  0.0, -225 => -0.7,
          -180 => -1.0, -135 => -0.7,  -90 =>  0.0,  -45 =>  0.7,
             0 =>  1.0,   45 =>  0.7,   90 =>  0.0,  135 => -0.7,
           180 => -1.0,  225 => -0.7,  270 =>  0.0,  315 =>  0.7, 360 =>  1.0 }

  def initialize( width=8, height=8 )
    @width = width
    @height = height

    @board = Array.new( width*height ) { Piece.empty }

    @coords = Array.new( board.length ) { |i| [i%width,i/width] }
    @coords.freeze

    @counts = {Piece.empty => board.length}
    @degree = 0
  end

  def initialize_copy( original )
    @width = original.width
    @height = original.height
    @board = Array.new( original.board.length ) { |i| original.board[i].dup }
    @coords = original.coords
    @counts = original.counts.dup
    @degree = original.degree
  end

  def []( x, y )
    @board[xy_to_i(x,y)]
  end

  def []=( x, y, piece )
    @counts[self[x,y]] -= 1
    @counts[piece] ||= 0
    @counts[piece] +=  1
    @board[xy_to_i(x,y)].become( piece )
  end

  def xy_to_i( x, y )
    x0,y0 = Board.rotate( x, y, -(degree%360) )
    x0.round+y0.round*width
  end

  def rotate( deg=45 )
    b = self.dup
    b.rotate!( deg )
  end

  def rotate!( deg=45 )
     @degree += deg
     new_coords = []
     coords.each do |x,y|
       new_coords << Board.rotate( x, y, deg )
     end
     @coords = new_coords
     @coords.sort! do |c1,c2|
       (t = c1[1] <=> c2[1]) != 0 ? t : c1[0] <=> c2[0]
     end
     @coords.freeze
     self
  end

  def Board.rotate( x, y, deg )
    [x*COS[deg]-y*SIN[deg],x*SIN[deg]+y*COS[deg]]
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
    17 + height.hash * 51 +
         width.hash  * 51 +
         board.hash  * 51
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

