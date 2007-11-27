# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying/rules'
require 'vying/board/board'

class Ataxx < Rules

  info :name      => 'Ataxx',
       :resources => ['Wikipedia <http://en.wikipedia.org/wiki/Ataxx>']

  attr_reader :board, :block_pattern, :moves_cache
  ignore :moves_cache

  players [:red, :blue]

  random

  def initialize( seed=nil )
    super

    @board = Board.new( 7, 7 )
    @board[:a1,:g7] = :red
    @board[:a7,:g1] = :blue

    @block_pattern = set_rand_blocks

    @moves_cache = :ns
  end

  def moves( player=nil )
    return []          unless player.nil? || has_moves.include?( player )
    return []          if players.any? { |p| board.count( p ) == 0 }
    return moves_cache if moves_cache != :ns

    p   = turn
    opp = (p == :red) ? :blue : :red

    cd = [:n, :s, :e, :w, :se, :sw, :ne, :nw]

    found = []

    # Adjacent moves

    board.occupied[p].each do |c|
      board.coords.ring( c, 1 ).each do |c1|
        found << "#{c}#{c1}" if board[c1].nil? && !c1.nil?
      end
    end

    # Jump moves

    board.occupied[p].each do |c|
      board.coords.ring( c, 2 ).each do |c2|
        found << "#{c}#{c2}" if board[c2].nil? && !c2.nil?
      end
    end

    @moves_cache = found
  end

  def apply!( move )
    coords, p = move.to_coords, turn
    opp = (p == :red) ? :blue : :red

    dx = (coords.first.x - coords.last.x).abs
    dy = (coords.first.y - coords.last.y).abs

    if dx <= 1 && dy <= 1 && (dx == 1 || dy == 1)
      board[coords.last] = turn
    else
      board.move( coords.first, coords.last )
    end

    board.coords.neighbors( coords.last ).each do |c|
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

