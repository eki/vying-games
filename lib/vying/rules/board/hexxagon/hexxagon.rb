# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying/rules'
require 'vying/board/board'

# Hexxagon is Ataxx played on a hex board.
#
# For detailed rules, etc:  http://vying.org/games/hexxagon

class Hexxagon < Rules

  name    "Hexxagon"
  version "0.5.0"

  players [:red, :blue]

  random

  attr_reader :board, :block_pattern, :moves_cache
  ignore :moves_cache

  def initialize( seed=nil, options={} )
    super

    @board = HexHexBoard.new( 5 )
    @board[:a1, :i5, :e9] = :red
    @board[:e1, :a5, :i9] = :blue

    @block_pattern = set_rand_blocks

    @moves_cache = :ns
  end

  def moves( player=nil )
    return []          unless player.nil? || has_moves.include?( player )
    return []          if players.any? { |p| board.count( p ) == 0 }
    return moves_cache if moves_cache != :ns

    p   = turn
    opp = (p == :red) ? :blue : :red

    found = []

    # Adjacent moves

    board.occupied[p].each do |c|
      board.ring( c, 1 ).each do |c1|
        found << "#{c}#{c1}" if board[c1].nil?
      end
    end

    # Jump moves

    board.occupied[p].each do |c|
      board.ring( c, 2 ).each do |c2|
        found << "#{c}#{c2}" if board[c2].nil?
      end
    end

    @moves_cache = found
  end

  def apply!( move )
    coords, p = move.to_coords, turn
    opp = (p == :red) ? :blue : :red

    if board.ring( coords.first, 1 ).include?( coords.last )
      board[coords.last] = turn
    else
      board.move( coords.first, coords.last )
    end

    board.coords.neighbors( coords.last, HexHexBoard::DIRECTIONS ).each do |c|
      board[c] = turn if board[c] == opp
    end

    turn( :rotate )
    @moves_cache = :ns

    turn( :rotate ) if moves.empty?
    @moves_cache = :ns

    self
  end

  def final?
    moves.empty?
  end

  def winner?( player )
    opp = player == :red ? :blue : :red
    board.count( player ) > board.count( opp )
  end

  def loser?( player )
    opp = player == :red ? :blue : :red
    board.count( player ) < board.count( opp )
  end

  def draw?
    board.count( :blue ) == board.count( :red )
  end

  def score( player )
    board.count( player )
  end

  def hash
    [board,turn].hash
  end

end

