# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying/rules'

# Cephalopod is a game invented by Mark Steere.  It involves filling a 5x5
# board with dice.
#
# For detailed rules see:  http://vying.org/games/three_musketeers

class Cephalopod < Rules

  name    "Cephalopod"
  version "0.9.0"

  players [:white, :black]

  attr_reader :board, :dice, :removing, :removing_coord, :removed

  COMBOS = { [1,1]     => 2,
             [1,2]     => 3,
             [1,3]     => 4,
             [1,4]     => 5,
             [1,5]     => 6,
             [2,2]     => 4,
             [2,3]     => 5,
             [2,4]     => 6,
             [3,3]     => 6,
             [1,1,1]   => 3,
             [1,1,2]   => 4,
             [1,1,3]   => 5,
             [1,1,4]   => 6,
             [1,2,2]   => 5,
             [1,2,3]   => 6,
             [2,2,2]   => 6,
             [1,1,1,1] => 4,
             [1,1,1,2] => 5,
             [1,1,1,3] => 6,
             [1,1,2,2] => 6 }

  def initialize( seed=nil )
    super

    @board = Board.new( 5, 5 )
    @dice = { :black => 0, :white => 0 }

    @removing, @removing_coord, @removed = 0, nil, 0
  end

  def moves( player=nil )
    return [] unless player.nil? || has_moves.include?( player )

    a = []

    # Remove dice

    if @removing > 0
      ns = board.coords.neighbors( removing_coord ).reject { |c| board[c].nil? }

      # If only one die is available, we can short circuit
      return ns.map { |c| c.to_s } if ns.length == 1

      # Any Die whose face value == @removing can be removed
      if removed > 0
        ns.each { |c| a << c.to_s if board[c].up == @removing }

        return a if a.length == ns.length
      end

      # Die that are apart of a combo adding up to @removing can be removed

      dice = Dice.new( board[*ns] )

      COMBOS.keys.each do |combo|
        if COMBOS[combo] == @removing && dice.include?( combo )
          combo.each { |f| ns.each { |c| a << c.to_s if board[c].up == f } }
        end

        a.uniq!

        return a if a.length == ns.length
      end

      return a
    end


    # Add a die

    board.coords.each do |c|
      next unless board[c].nil?

      np = board[*board.coords.neighbors( c, [:n, :e, :w, :s] )]
      dice = Dice.new( np.compact )

      capturing = false

      COMBOS.keys.each do |combo|
        if dice.include?( combo )
          capturing = true
          a << "#{COMBOS[combo]}#{c}"
        end
      end

      a << "1#{c}" unless capturing
    end

    a
  end

  def apply!( move )
    if move =~ /([123456])(\w+)/           # Place a die on the board
      p = $1.to_i
      c = Coord[$2]

      board[c] = Die.new( p, turn )
      dice[turn] += 1

      if p > 1 
        @removing, @removing_coord, @removed = p, c, 0
      else
        turn( :rotate )
      end

    else                                   # Remove a die from the board
      c = Coord[move]
      p, board[c] = board[c], nil
      @removing -= p.up
      @removed += 1

      if @removing == 0
        turn( :rotate )
      end
    end

    self
  end

  def final?
    moves.empty?
  end

  def winner?( player )
    opp = player == :black ? :white : :black
    dice[player] > dice[opp]
  end

  def loser?( player )
    opp = player == :black ? :white : :black
    dice[player] < dice[opp]
  end

  def score( player )
    dice[player]
  end

  def hash
    [board,turn].hash
  end
end

