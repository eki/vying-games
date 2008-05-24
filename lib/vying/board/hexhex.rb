require 'vying/board/coord'
require 'vying/board/coords'

class HexHexBoard < Board

  attr_reader :length

  DIRECTIONS = [:n, :s, :e, :w, :nw, :se]

  def initialize( length=10 )
    @length, @width, @height = length, length*2-1, length*2-1
    @cells = Array.new( @width * @height, nil )

    omit = []
    @width.times do |x|
      @height.times do |y|
        omit << Coord[x,y] if (x - y).abs >= length
      end
    end

    @coords = Coords.new( @width, @height, omit )
    @occupied = {}
  end

end

