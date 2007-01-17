require 'vying/board/board'

class OthelloBoard < Board

  attr_reader :occupied, :frontier

#  def initialize( w=8, h=8 )
#    super
#
#    self[3,3] = self[4,4] = :white
#    self[3,4] = self[4,3] = :black
#
#    @occupied = [Coord[3,3], Coord[4,4], Coord[3,4], Coord[4,3]]
#    @frontier = occupied.map { |c| coords.neighbors( c ) }
#    @frontier = @frontier.flatten.select { |c| self[c].nil? }.uniq
#  end

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

