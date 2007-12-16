# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying/rules'

class Frames < Rules

  name    "Frames"
  version "0.3.0"

  players [:black, :white]

  attr_reader :board, :sealed_moves, :unused_moves, :points

  @@init_moves = Coords.new( 19, 19 ).map { |c| c.to_s }

  def initialize( seed=nil )
    super

    @board = Board.new( 19, 19 )
    @sealed_moves = { :black => nil, :white => nil }
    @points = { :black => 0, :white => 0 }
    @unused_moves = {}
    players.each do |p|
      @unused_moves[p] = @@init_moves.dup.map { |m| "#{p}_#{m}" }
    end
  end

  def has_moves
    final? ? [] : players.select { |p| ! sealed_moves[p] }
  end

  def moves( player=nil )
    return [] unless player.nil? || has_moves.include?( player )
    return [] if final?

    return unused_moves[player] if player
    unused_moves.values.flatten
  end

  def apply!( move )
    player, coord = move.to_s.split( /_/ )
    player = player.intern
    coord = Coord[coord]

    sealed_moves[player] = coord

    if sealed_moves[:black] && sealed_moves[:white]
      if sealed_moves[:black] == sealed_moves[:white]
        board[coord] = :neutral
      else
        fb = sealed_moves[:black]
        fw = sealed_moves[:white]

        board[fb], board[fw] = :black, :white

        count = { :black => 0, :white => 0 }
        max_x, min_x = [fb.x, fw.x].max, [fb.x, fw.x].min
        max_y, min_y = [fb.y, fw.y].max, [fb.y, fw.y].min
       
        board.coords.each do |c|
          if (board[c] == :black || board[c] == :white) &&
             (min_x < c.x && c.x < max_x && min_y < c.y && c.y < max_y)
            count[board[c]] += 1
          end
        end
        
        points[:black] += 1 if count[:black] > count[:white]
        points[:white] += 1 if count[:white] > count[:black]
      end

      players.each do |p|
        unused_moves[p].delete( sealed_moves[p] )
        sealed_moves[p] = nil
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
    [board,points,sealed_moves].hash
  end

  def censor( player )
    position = super( player )

    players.each do |p|
      if p != player && ! position.sealed_moves[p].nil?
        position.sealed_moves[p] = :hidden
      end
    end

    position
  end

  def turn
    has_moves.first
  end

end

