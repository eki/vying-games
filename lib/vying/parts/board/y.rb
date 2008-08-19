
require 'vying'

class YBoard < Board

  DIRECTIONS = [:n, :s, :e, :w, :ne, :sw]

  def initialize( length=12 )
    @width, @height = length, length
    @cells = Array.new( @width * @height, nil )

    omit = []
    @width.times do |x|
      @height.times do |y|
        omit << Coord[x,y] if x + y >= length
      end
    end

    @coords = Coords.new( @width, @height, omit )
    @occupied = { nil => @coords.to_a.dup }
  end

end

