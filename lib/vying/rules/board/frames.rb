# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying/rules'

class Frames < Rules

  name    "Frames"
  version "0.4.0"

  players [:black, :white]

  attr_reader :board, :sealed, :unused, :points, :frame
  ignore :unused

  @@init_moves = Coords.new( 19, 19 ).map { |c| c.to_s }

  def initialize( seed=nil )
    super

    @board = Board.new( 19, 19 )
    @sealed = { :black => nil, :white => nil }
    @points = { :black => 0, :white => 0 }
    @frame = []
    @unused = {}
    players.each do |p|
      @unused[p] = @@init_moves.dup.map { |m| "#{p}_#{m}" }
    end
  end

  def has_moves
    final? ? [] : players.select { |p| ! sealed[p] }
  end

  def moves( player=nil )
    return [] unless player.nil? || has_moves.include?( player )
    return [] if final?

    return unused[player] if player

    return unused[:white] if sealed[:black] && ! sealed[:white]
    return unused[:black] if sealed[:white] && ! sealed[:black]

    unused.values.flatten
  end

  def apply!( move )
    player, coord = move.to_s.split( /_/ )
    player = player.intern
    coord = Coord[coord]

    sealed[player] = coord

    if sealed[:black] && sealed[:white]
      if sealed[:black] == sealed[:white]
        board[coord] = :neutral
        frame.clear
      else
        fb = sealed[:black]
        fw = sealed[:white]

        board[fb], board[fw] = :black, :white

        count = { :black => 0, :white => 0 }
        max_x, min_x = [fb.x, fw.x].max, [fb.x, fw.x].min
        max_y, min_y = [fb.y, fw.y].max, [fb.y, fw.y].min
      
        if max_x > min_x + 1 && max_y > min_y +1 
          board.coords.each do |c|
            if (board[c] == :black || board[c] == :white) &&
               (min_x < c.x && c.x < max_x && min_y < c.y && c.y < max_y)
              count[board[c]] += 1
            end
          end
        
          points[:black] += 1 if count[:black] > count[:white]
          points[:white] += 1 if count[:white] > count[:black]

          frame.replace [fb, fw]
        else
          frame.clear
        end
      end

      players.each do |p|
        unused[:black].delete( "black_#{sealed[p]}" )
        unused[:white].delete( "white_#{sealed[p]}" )
        sealed[p] = nil
      end
    end

    self
  end

  def final?
    points.any? { |n| n == 10 }
  end

  def winner?( player )
    points[player] == 10
  end

  def loser?( player )
    points[player] != 10
  end

  def score( player )
    points[player]
  end

  def hash
    [board,points,sealed].hash
  end

  def censor( player )
    position = super( player )

    players.each do |p|
      if p != player && ! position.sealed[p].nil?
        position.sealed[p] = :hidden
      end
    end

    position
  end

  def turn
    has_moves.first
  end

end

