
require 'vying/board/coords'
require 'vying/board/boardext'

class Board

  attr_reader :coords, :cells, :width, :height, :occupied
  protected :cells

  def initialize( w=8, h=8 )
    @width, @height, @cells = w, h, Array.new( w*h, nil )
    @coords = Coords.new( width, height )
    @occupied = {}
  end

  def initialize_copy( original )
    @cells = original.cells.dup
    @occupied = {}
    original.occupied.each { |k,v| @occupied[k] = v.dup }
  end

  def ==( o )
    o.respond_to?( :cells ) && o.respond_to?( :width ) &&
    o.width == width && cells == o.cells
  end

  def hash
    [cells,width].hash
  end

  def count( p )
    return (occupied[p] || []).length if p
    width * height - occupied.inject(0) { |m,v| m + v[1].length }
  end

  def row( y )
    (0...width).map { |x| cells[ci(x,y)] }
  end

  def move( sc, ec )
    self[sc], self[ec] = nil, self[sc]
    self
  end

  def unoccupied
    coords.select { |c| self[c].nil? }
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

  def clear
    @cells.each_index { |i| @cells[i] = nil }
    @occupied = Hash.new { |h,k| h[k] = [] }
    self
  end
  
  def to_s
    off = height >= 10 ? 2 : 1                                
    w = width

    letters = ' '*off + 'abcdefghijklmnopqrstuvwxyz'[0..(w-1)] + ' '*off + "\n"

    s = letters
    height.times do |y|
      s += sprintf( "%*d", off, y+1 )
      s += row(y).inject( '' ) do |rs,p|
        rs + (p.nil? ? ' ' : p.to_s[0..0])
      end
      s += sprintf( "%*d\n", -off, y+1 )
    end
    s + letters
  end

end

