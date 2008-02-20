# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying/board/board'

class OthelloBoard < Board

  attr_reader :occupied, :frontier

  INITIAL_FRONTIER = [Coord[2,2], Coord[3,2], Coord[4,2], Coord[5,2],
                      Coord[5,3], Coord[5,4], Coord[5,5], Coord[4,5],
                      Coord[3,5], Coord[2,5], Coord[2,4], Coord[2,3]]

  def initialize
    super( 8, 8 )

    @cells[27] = @cells[36] = :white
    @cells[35] = @cells[28] = :black

    @occupied = { :black => [Coord[3,4], Coord[4,3]],
                  :white => [Coord[3,3], Coord[4,4]] }
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

