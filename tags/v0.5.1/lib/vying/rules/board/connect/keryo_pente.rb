# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying/rules'
require 'vying/board/connect6'

class KeryoPente < Rules

  name    "Keryo-Pente"
  version "1.0.0"

  players [:white, :black]

  attr_reader :board, :lastc, :lastp, :unused_moves, :captured

  @@init_moves = Coords.new( 19, 19 ).map { |c| c.to_s }

  def initialize( seed=nil )
    super

    @board = Connect6Board.new( 5 )
    @lastc, @lastp = nil, :noone
    @unused_moves = @@init_moves.dup

    @captured = { :black => 0, :white => 0 }
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

    # Custodian capture
    cap = []
    directions = [:n,:s,:e,:w,:ne,:nw,:se,:sw]
    a = directions.zip( board.coords.neighbors_nil( c, directions ) )
    a.each do |d,nc|
      next if board[nc].nil? || board[nc] == board[c]

      bt = [nc]
      while (bt << board.coords.next( bt.last, d ))
        break if board[bt.last].nil?
        break if bt.length < 3 && board[bt.last] == board[c]
        break if bt.length > 4

        if (bt.length == 3 || bt.length == 4) && board[bt.last] == board[c]
          bt.each { |bc| cap << bc unless board[bc] == board[c] }
          break
        end
      end
    end

    cap.each do |cc|  
      board[cc] = nil
      board.update_threats( cc )
      captured[turn] += 1
      @unused_moves << cc.to_s
    end

    turn( :rotate )
    self
  end

  def final?
    return false if lastc.nil?
    return true  if unused_moves.empty?

    return true if captured[:black] >= 15 || captured[:white] >= 15

    board.each_from( lastc, [:e,:w] ) { |p| p == lastp } >= 4 ||
    board.each_from( lastc, [:n,:s] ) { |p| p == lastp } >= 4 ||
    board.each_from( lastc, [:ne,:sw] ) { |p| p == lastp } >= 4 ||
    board.each_from( lastc, [:nw,:se] ) { |p| p == lastp } >= 4
  end

  def winner?( player )
    captured[player] >= 15 ||
    lastp == player &&
    (board.each_from( lastc, [:e,:w] ) { |p| p == player } >= 4 ||
     board.each_from( lastc, [:n,:s] ) { |p| p == player } >= 4 ||
     board.each_from( lastc, [:ne,:sw] ) { |p| p == player } >= 4 ||
     board.each_from( lastc, [:nw,:se] ) { |p| p == player } >= 4)
  end

  def loser?( player )
    !draw? && player != lastp
  end

  def draw?
    captured[:black] < 15 &&
    captured[:white] < 15 &&
    unused_moves.empty? &&
    board.each_from( lastc, [:e,:w] ) { |p| p == lastp } < 4 &&
    board.each_from( lastc, [:n,:s] ) { |p| p == lastp } < 4 &&
    board.each_from( lastc, [:ne,:sw] ) { |p| p == lastp } < 4 &&
    board.each_from( lastc, [:nw,:se] ) { |p| p == lastp } < 4
  end

  def score( player )
    captured[player]
  end

  def hash
    [board, captured, turn].hash
  end
end

