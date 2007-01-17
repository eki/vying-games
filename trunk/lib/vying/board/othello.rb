require 'vying/board/board'

class OthelloBoard < Board

  attr_reader :occupied, :frontier

  INITIAL_OCCUPIED = [Coord[3,3], Coord[4,4], Coord[3,4], Coord[4,3]]

  INITIAL_FRONTIER = [Coord[2,2], Coord[3,2], Coord[4,2], Coord[5,2],
                      Coord[5,3], Coord[5,4], Coord[5,5], Coord[4,5],
                      Coord[3,5], Coord[2,5], Coord[2,4], Coord[2,3]]

  def initialize
    super( 8, 8 )

    self[3,3] = self[4,4] = :white
    self[3,4] = self[4,3] = :black

    @occupied = INITIAL_OCCUPIED.dup
    @frontier = INITIAL_FRONTIER.dup
  end

  def initialize_copy( original )
    super
    @occupied = original.occupied.dup
    @frontier = original.frontier.dup
  end

#  def valid?( c, bp, directions = [:n,:s,:w,:e,:ne,:nw,:se,:sw] )
#    return false if !self[c].nil?
#
#
#    op = bp == :black ? :white : :black
#
#    a = directions.zip( coords.neighbors_nil( c, directions ) )
#    a.each do |d,nc|
#      p = self[nc]
#      next if p.nil? || p == bp
#
#      i = nc
#      while (i = coords.next( i, d ))
#        p = self[i]
#        return true if p == bp 
#        break       if p.nil?
#      end
#    end
#
#    false
#  end
#
#  def place( c, bp )
#    op = bp == :black ? :white : :black
#
#    directions = [:n,:s,:w,:e,:ne,:nw,:se,:sw]
#
#    a = directions.zip( coords.neighbors_nil( c, directions ) )
#    a.each do |d,nc|
#      p = self[nc]
#      next if p.nil? || p == bp
#
#      bt = [nc]
#      while (bt << coords.next( bt.last, d ))
#        p = self[bt.last]
#        break if p.nil?
#
#        if p == bp
#          bt.each { |bc| self[bc] = bp }
#          break
#        end
#      end
#    end
#
#    self[c] = bp
#  end
end

