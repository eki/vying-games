
require 'vying'

class HexHexBoard < Board

  attr_reader :length

  DIRECTIONS = [:n, :s, :e, :w, :nw, :se]

  def initialize( length=10 )
    @length, @width, @height = length, length*2-1, length*2-1
    @cells = Array.new( @width * @height, nil )
    @coords = HexHexBoard.coords( length )
    @occupied = { nil => @coords.to_a.dup }
  end

  def self.coords( length=10 )
    width, height, omit = length*2-1, length*2-1, []
    width.times do |x|
      height.times do |y|
        omit << Coord[x,y] if (x - y).abs >= length
      end
    end

    Coords.new( width, height, omit )
  end

  def self.edges( length=10 )
    s1, s12 = length-1, (length-1) * 2

    cs = HexHexBoard.coords( length ).select do |c|
      c.x == 0        || c.y == 0        || 
      c.x == s12      || c.y == s12      || 
      c.x - c.y == s1 || c.y - c.x == s1
    end
  end

  def ring( coord, d )
    dc = Coord[coord.x - d, coord.y - d]
    ring = HexHexBoard.edges( d+1 ).map { |c| c + dc }
    ring.select { |c| coords.include?( c ) }
  end

  extend Memoizable

  class << self
    extend Memoizable
    memoize :coords
    memoize :edges
  end

end

