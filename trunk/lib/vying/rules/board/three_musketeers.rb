# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying/rules'

# 
# 
# 
#
# For detailed rules see:  http://vying.org/games/amazons

class ThreeMusketeers < Rules

  info :name      => "Three Musketeers",
       :resources => 
         ['Wikipedia <http://en.wikipedia.org/wiki/Three_Musketeers_(game)>']

  attr_reader :board

  players [:red, :blue]

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
    return [] if turn == :blue && final?

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
    (turn == :red && moves.empty?) ||
    (turn == :blue && 
     (board.occupied[:red].map { |c| c.x }.uniq.length == 1 ||
      board.occupied[:red].map { |c| c.y }.uniq.length == 1))
  end

  def winner?( player )
    turn == player
  end

  def loser?( player )
    turn != player
  end

  def hash
    [board,turn].hash
  end
end

