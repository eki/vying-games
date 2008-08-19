
require 'vying'

class YinshBoard < Board

  OMIT_COORDS = [:a1,  :a6,  :a7,  :a8,  :a9, :a10, :a11,
                 :b8,  :b9,  :b10, :b11,
                 :c9,  :c10, :c11,
                 :d10, :d11,
                 :e11,
                 :f1,  :f11,
                 :g1,
                 :h1,  :h2,
                 :i1,  :i2,  :i3,
                 :j1,  :j2,  :j3,  :j4,
                 :k1,  :k2,  :k3,  :k4,  :k5, :k6,  :k11].map { |c| Coord[c] }

  DIRECTIONS = [:n, :s, :e, :w, :nw, :se]

  def initialize
    @width, @height = 11, 11
    @cells = Array.new( @width * @height, nil )
    @coords = Coords.new( @width, @height, OMIT_COORDS )
    @occupied = { nil => @coords.to_a.dup }
  end

end

