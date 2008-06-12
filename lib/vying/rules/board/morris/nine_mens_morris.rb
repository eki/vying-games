# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying/rules'
require 'vying/board/board'

class NineMensMorris < Rules

  name    "Nine Men's Morris"
  version "1.0.0"

  players [:black, :white]

  allow_draws_by_agreement

  attr_reader :board, :remaining, :removing

  def initialize( seed=nil, options={} )
    super

    @board = Board.new( 7, 7 )

    @board[:a2,:a3,:a5,:a6,
           :b1,:c1,:e1,:f1,
           :b7,:c7,:e7,:f7,
           :g2,:g3,:g5,:g6,
           :b3,:b5,
           :c2,:e2,
           :c6,:e6,
           :f3,:f5] = :x
    @board[:d4] = :X

    @remaining = { :black => 9, :white => 9 }
    @removing = false
  end

  def initialize_copy( original )
    super

    r = original.remaining
    @remaining = { :black => r[:black], :white => r[:white] }
  end

  def moves( player=nil )
    return [] unless player.nil? || has_moves.include?( player )

    if remaining[:black] == 0 && remaining[:white] == 0 &&
       (board.occupied[:black].length == 2 || 
        board.occupied[:white].length == 2)
      return []
    end

    found = []

    # Removing an opponent's stone

    if removing
      opp = turn == :black ? :white : :black

      all = []

      board.occupied[opp].each do |c|
        all << cs = "#{c}"
        found << cs unless mill?( c )
      end

      return found.empty? ? all : found
    end

    # Placing stones

    if remaining[turn] > 0
      return board.coords.select { |c| board[c].nil? }.map { |c| c.to_s }
    end

    # Moving stones

    if board.occupied[turn].length > 3
      board.occupied[turn].each do |c|
        [:n, :e, :s, :w].each do |d|
          p1 = board[c1 = board.coords.next( c, d )]
          until p1 != :x
            p1 = board[c1 = board.coords.next( c1, d)]
          end

          found << "#{c}#{c1}" if p1.nil? && ! c1.nil?
        end
      end

      # If we couldn't find any moves, the game is over
      return found
    end

    # Flying

    board.occupied[turn].each do |c|
      board.unoccupied.each do |c1|
        found << "#{c}#{c1}"
      end
    end

    found
  end

  def apply!( move, player=nil )
    coords, c = move.to_coords, nil

    if removing
      board[coords.first], @removing = nil, false

    elsif coords.length == 1
      board[coords.first] = turn
      remaining[turn] -= 1
      c = coords.first

    elsif coords.length == 2
      board.move( coords.first, coords.last )
      c = coords.last
    end

    if mill?( c )
      @removing = true
    else
      turn( :rotate )
    end

    self
  end

  def final?
    moves.empty?
  end

  def winner?( player )
    opp = player == :black ? :white : :black

    final? && (
    (board.occupied[player].length > 2 && board.occupied[player].length == 2) ||
    (turn != player) )
  end

  def loser?( player )
    opp = player == :black ? :white : :black

    final? && (
    (board.occupied[player].length == 2 && board.occupied[player].length > 2) ||
    (turn == player) )
  end

  def score( player )
    opp = player == :black ? :white : :black
    opp_p = board.occupied[opp]
    9 - remaining[opp] - (opp_p ? opp_p.length : 0)
  end

  def hash
    [board,remaining,removing,turn].hash
  end

  MILLS = [[:a1,:d1,:g1], [:g1, :g4, :g7], [:g7, :d7, :a7], [:a7, :a4, :a1],
           [:b2,:d2,:f2], [:f2, :f4, :f6], [:f6, :d6, :b6], [:b6, :b4, :b2],
           [:c3,:d3,:e3], [:e3, :e4, :e5], [:e5, :d5, :c5], [:c5, :c4, :c3],
           [:d1,:d2,:d3], [:d7, :d6, :d5], [:a4, :b4, :c4], [:g4, :f4, :e4]].
           map { |a| a.map { |c| Coord[c] } }

  def mill?( coord )
    p = board[coord]

    MILLS.each do |mill|
      if mill.include?( coord ) && board[*mill].all? { |p1| p1 == p }
        return true
      end
    end

    false
  end

end

