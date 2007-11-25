# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying/rules'
require 'vying/board/connect6'

class Connect6 < Rules

  info :name      => 'Connect6',
       :resources => ['Wikipedia <http://en.wikipedia.org/wiki/Connect6>'],
       :related   => ["Pente", "KeryoPente", "Connect4", "TicTacToe"]

  attr_reader :board, :lastc, :lastp, :unused_moves

  allow_draws_by_agreement

  players [:black, :white]

  @@init_moves = Coords.new( 19, 19 ).map { |c| c.to_s }

  def initialize( seed=nil )
    super

    @board = Connect6Board.new
    @turn = [:black, :white, :white, :black]
    @lastc, @lastp = nil, :noone
    @unused_moves = @@init_moves.dup
  end

  def moves( player=nil )
    return [] unless player.nil? || has_moves.include?( player )
    return [] if final?
    unused_moves
  end

  def apply!( move )
    c, p = Coord[move], turn
    board[c], @lastc, @lastp = p, c, p
    board.update_threats( c )
    @unused_moves.delete( c.to_s )
    turn( :rotate )
    self
  end

  def final?
    return false if lastc.nil?
    return true  if unused_moves.empty?

    board.each_from( lastc, [:e,:w] ) { |p| p == lastp } >= 5 ||
    board.each_from( lastc, [:n,:s] ) { |p| p == lastp } >= 5 ||
    board.each_from( lastc, [:ne,:sw] ) { |p| p == lastp } >= 5 ||
    board.each_from( lastc, [:nw,:se] ) { |p| p == lastp } >= 5
  end

  def winner?( player )
    lastp == player &&
    (board.each_from( lastc, [:e,:w] ) { |p| p == player } >= 5 ||
     board.each_from( lastc, [:n,:s] ) { |p| p == player } >= 5 ||
     board.each_from( lastc, [:ne,:sw] ) { |p| p == player } >= 5 ||
     board.each_from( lastc, [:nw,:se] ) { |p| p == player } >= 5)
  end

  def loser?( player )
    !draw? && player != lastp
  end

  def draw?
    unused_moves.empty? &&
    board.each_from( lastc, [:e,:w] ) { |p| p == lastp } < 5 &&
    board.each_from( lastc, [:n,:s] ) { |p| p == lastp } < 5 &&
    board.each_from( lastc, [:ne,:sw] ) { |p| p == lastp } < 5 &&
    board.each_from( lastc, [:nw,:se] ) { |p| p == lastp } < 5
  end

  def hash
    [board,turn].hash
  end
end

