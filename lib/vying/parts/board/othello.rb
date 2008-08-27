# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

class OthelloBoard < Board

  attr_reader :occupied, :frontier

  INITIAL_FRONTIER = [:c3, :d3, :e3, :f3, :f4, :f5, :f6, :e6, 
                      :d6, :c6, :c5, :c4].map { |c| Coord[c] }

  def initialize
    super( 8, 8 )

    # Avoiding frontier update by not using #[]=

    @cells[35] = @cells[28] = :black   # self[:d5, :e4] = :black
    @cells[27] = @cells[36] = :white   # self[:d4, :e5] = :white

    # While avoiding the frontier update, we also avoided updating occupied...

    @occupied[:black] = [Coord[:d5], Coord[:e4]]
    @occupied[:white] = [Coord[:d4], Coord[:e5]]

    @frontier = INITIAL_FRONTIER.dup
  end

  def initialize_copy( original )
    super
    @frontier = original.frontier.dup
  end

  def clear
    @frontier.clear
    super
  end

end

