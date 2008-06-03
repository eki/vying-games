# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying/rules'

# Dots and Boxes
#
# For detailed rules see:  http://vying.org/games/dots_and_boxes

class DotsAndBoxes < Rules

    name    "Dots and Boxes"
    version "1.0.0"

    players [:black, :white]
  
    attr_reader :grid

    def initialize( seed=nil, options={} )
      super

      @grid = Grid.new
    end

    def moves( player=nil )
      return [] unless player.nil? || has_moves.include?( player )

      lines = grid.lines.keys.select { |k| ! grid.lines[k] }
      lines.map { |line| "#{line.first}:#{line.last}" }
    end

    def moves_that_complete_boxes( player=nil )
      return [] unless player.nil? || has_moves.include?( player )

      lines = grid.lines.keys.select { |k| ! grid.lines[k] }

      lines = lines.select { |line| grid.will_complete_box?( *line ) }
      lines.map { |line| "#{line.first}:#{line.last}" }
    end

    def apply!( move )
      move =~ /(\d+):(\d+)/

      d1 = $1.to_i
      d2 = $2.to_i

      grid.line( d1, d2 )

      # Check to see if a box was completed
      completed_box = false

      directions = (d1 - d2).abs == 1 ? [:s, :n] : [:e, :w]

      directions.each do |dir|
        d3, d4 = grid.next( d1, dir ), grid.next( d2, dir )
        if grid[d1, d3] && grid[d2, d4] && grid[d3, d4]
          grid[d1, d2, d3, d4] = turn
          completed_box = true
        end
      end

      turn( :rotate ) unless completed_box

      self
    end

    def final?
      grid.boxes.values.all? { |v| v }
    end

    def winner?( player )
      opp = player == :white ? :black : :white
      score( player ) > score( opp )
    end

    def loser?( player )
      opp = player == :white ? :black : :white
      score( player ) < score( opp )
    end

    def draw?
      score( :white ) == score( :black )
    end

    def score( player )
      grid.boxes.values.select { |v| v == player }.length
    end

    def hash
      [grid,turn].hash
    end

end

