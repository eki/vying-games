# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying/rules'

# Cephalopod is a game invented by Mark Steere.  It involves filling a 5x5
# board with dice.
#
# For detailed rules see:  http://vying.org/games/three_musketeers

class Cephalopod < Rules

  name    "Cephalopod"
  version "0.9.1"

  players [:white, :black]

  attr_reader :board, :dice, :removed, :removed

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

    @removed = {}
  end

  def moves( player=nil )
    return [] unless player.nil? || has_moves.include?( player )

    a = []

    # Remove dice

    qs = board.occupied["?"] || []
    unless qs.empty?
      cc = qs.first
      ns = board.coords.neighbors( cc, [:n, :e, :w, :s] ).
             reject { |c| board[c].nil? }
      
      removed_faces = @removed.values.map { |d| d.up }.sort
      ns_dice = {}
      ns.each do |c|
        ns_dice[c] = @removed.values.map { |d| d.up }
        ns_dice[c] << board[c].up
        ns_dice[c].sort!
      end

      o_dice = Dice.new( [board[*ns]].flatten )

      COMBOS.keys.each do |combo|
        ns_dice.each do |c, dice|
          if dice == combo
            a << c.to_s
          end
        end

        if removed_faces.empty?
          if o_dice.include?( combo )
            combo.each { |f| ns.each { |c| a << c.to_s if board[c].up == f } }
          end
        end

        if removed_faces == combo
          a << cc.to_s
        end
      end

      return a.uniq
    end

    # Add a die

    board.coords.each do |c|
      next unless board[c].nil?

      a << "#{c}"
    end

    a
  end

  def apply!( move )
    c = Coord[move]
    if board[c].nil?
      np = board[*board.coords.neighbors( c, [:n, :e, :w, :s] )]
      dice = Dice.new( np.compact )

      capturing = false

      COMBOS.keys.each do |combo|
        if dice.include?( combo )
          capturing = true
        end
      end

      if capturing
        board[c] = "?" 
      else
        board[c] = Die.new( 1, turn )
        @dice[turn] += 1
        turn( :rotate )
      end

    elsif board[c] == "?"
      board[c] = Die.new( @removed.values.inject( 0 ) { |m,d| m + d.up }, turn )
      @dice[turn] += 1
      @removed.clear
      turn( :rotate )

    else
      p, board[c] = board[c], nil
      @removed[c] =  p
      @dice[p.color] -= 1
    end

    self
  end

  def final?
    board.empty_count == 0 && (board.occupied["?"] || []).empty?
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

