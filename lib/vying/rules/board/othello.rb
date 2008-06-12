# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying/rules'
require 'vying/board/othello'

class Othello < Rules

  name    "Othello"
  version "1.0.0"
  notation :othello_notation

  players [:black, :white]

  score_determines_outcome

  attr_reader :board, :moves_cache
  ignore :moves_cache

  def initialize( seed=nil, options={} )
    super

    @board = OthelloBoard.new
    @moves_cache = :ns
  end

  def frontier
    @board.frontier
  end

  def occupied
    @board.occupied
  end

  def move?( move, player=nil )
    return false unless player.nil? || has_moves.include?( player )
    board.valid?( Coord[move], turn )
  end

  def moves( player=nil )
    return []          unless player.nil? || has_moves.include?( player )
    return moves_cache if moves_cache != :ns
    a = frontier.select { |c| board.valid?( c, turn ) }.map { |c| c.to_s }
    @moves_cache = a
  end

  def apply!( move, player=nil )
    c = Coord[move]
    board.place( c, turn )

    turn( :rotate )
    @moves_cache = :ns
    return self unless moves.empty?

    turn( :rotate )
    @moves_cache = :ns

    self
  end

  def final?
    moves.empty?
  end

  def score( player )
    board.count( player )
  end

  def hash
    [board, turn].hash
  end
end

