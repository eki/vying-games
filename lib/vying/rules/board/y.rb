# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying/rules'

# Y
#
# For detailed rules see:  http://vying.org/games/y

class Y < Rules

  name    "Y"
  version "0.0.1"

  players [:blue, :red]

  attr_reader :board, :groups

  def initialize( seed=nil )
    super

    @board = YBoard.new
    @groups = { :blue => [], :red => [] }
  end

  def moves( player=nil )
    return []          unless player.nil? || has_moves.include?( player )

    board.unoccupied
  end

  def apply!( move )
    coord = Coord[move]

    board[coord] = turn

    new_groups = []
    YBoard::DIRECTIONS.each do |d|
      n = board.coords.next( coord, d )
      groups[turn].delete_if do |g|
        if g.include?( n )
          g << coord
          new_groups << g
        end
      end
    end

    if new_groups.empty?
      groups[turn] << [coord]
    else
      groups[turn] += new_groups.inject( [] ) { |m,a| m | a }
    end

    turn( :rotate )

    self
  end

  def final?
    players.any? { |p| winner?( p ) }
  end

  def winner?( player )
    groups[player].each do |group|
      sides = 0
      group.each do |c|
        sides |= 1  if c.x == 0
        sides |= 2  if c.y == 0
        sides |= 4  if c.x + c.y == board.length - 1
        return true if sides == 7
      end
    end

    false
  end

  def loser?( player )
    opp = player == :blue ? :red : :blue
    winner?( opp )
  end

  def hash
    [board,turn].hash
  end
end

