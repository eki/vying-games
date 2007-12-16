# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying/rules'

# Three Musketeers is a simple board game with nonsymmetric objectives.  The
# red player wins by running out of moves.  The blue player wins by aligning
# all the red pieces on any single row or column.
#
# For detailed rules see:  http://vying.org/games/three_musketeers

class ThreeMusketeers < Rules

  name    "Three Musketeers"
  version "1.0.0"

  players [:red, :blue]

  attr_reader :board

  def initialize( seed=nil )
    super

    @board = Board.new( 5, 5 )
    @board[:a1,:b1,:c1,:d1,    
           :a2,:b2,:c2,:d2,:e2,
           :a3,:b3,    :d3,:e3,
           :a4,:b4,:c4,:d4,:e4,
               :b5,:c5,:d5,:e5] = :blue

    @board[:a5,:c3,:e1] = :red
  end

  def moves( player=nil )
    return [] unless player.nil? || has_moves.include?( player )
    return [] if (turn == :blue && 
     (board.occupied[:red].map { |c| c.x }.uniq.length == 1 ||
      board.occupied[:red].map { |c| c.y }.uniq.length == 1))

    a = []

    if turn == :red
      musketeers = board.occupied[:red]
      musketeers.each do |c|
        board.coords.neighbors( c, [:n,:e,:w,:s] ).each do |n|
          a << "#{c}#{n}" if board[n] == :blue
        end
      end
    else
      enemies = board.occupied[:blue]
      enemies.each do |c|
        board.coords.neighbors( c, [:n,:e,:w,:s] ).each do |n|
          a << "#{c}#{n}" if board[n].nil?
        end
      end
    end

    a
  end

  def apply!( move )
    coords = move.to_coords

    board.move( coords.first, coords.last )
    turn( :rotate )

    self
  end

  def final?
    moves.empty?
  end

  def winner?( player )
     bw = (board.occupied[:red].map { |c| c.x }.uniq.length == 1 ||
           board.occupied[:red].map { |c| c.y }.uniq.length == 1)
     player == :red ? !bw : bw
  end

  def loser?( player )
     bw = (board.occupied[:red].map { |c| c.x }.uniq.length == 1 ||
           board.occupied[:red].map { |c| c.y }.uniq.length == 1)
     player == :red ? bw : !bw
  end

  def hash
    [board,turn].hash
  end
end

