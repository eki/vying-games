
require 'vying/board/coords'
require 'vying/board/boardext'

class Board

  attr_reader :coords
  protected :cells

  def coords
    @coords = Coords.new( width, height )
  end

  def ==( o )
    o.respond_to?( :cells ) && o.respond_to?( :width ) &&
    o.width == width && cells == o.cells
  end

  def hash
    [cells,width].hash
  end

  def count( p )
    cells.select { |i| i == p }.length
  end

  def row( y )
    (0...width).map { |x| cells[ci(x,y)] }
  end

  def move( sc, ec )
    self[sc], self[ec] = nil, self[sc]
    self
  end

  def each
    coords.each { |c| yield self[c] }
  end

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
  
  def to_s
    off = height >= 10 ? 2 : 1                                
    w = width

    letters = ' '*off + 'abcdefghijklmnopqrstuvwxyz'[0..(w-1)] + ' '*off + "\n"

    s = letters
    height.times do |y|
      s += sprintf( "%*d", off, y+1 )
      s += row(y).inject( '' ) do |rs,p|
        rs + (p.nil? ? ' ' : p.to_s[0..0].downcase)
      end
      s += sprintf( "%*-d\n", off, y+1 )
    end
    s + letters
  end

end

