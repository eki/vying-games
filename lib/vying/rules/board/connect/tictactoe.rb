# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

Rules.create( "TicTacToe" ) do
  name    "Tic Tac Toe"
  version "1.0.0"

  players :x, :o

  position do
    attr_reader :board, :lastc, :lastp
    ignore :lastc, :lastp
  
    def init
      @board = Board.new( 3, 3 )
      @lastc, @lastp = nil, :noone
    end

    def moves( player=nil )
      return [] unless player.nil? || has_moves.include?( player )
      return [] if final?
      board.unoccupied
    end

    def apply!( move, player=nil )
      c, p = Coord[move], turn
      board[c], @lastc, @lastp = p, c, p
      rotate_turn
      self
    end

    def final?
      return false if lastc.nil?
      return true  if board.unoccupied.empty?

      board.each_from( lastc, [:e,:w] ) { |p| p == lastp } == 2 ||
      board.each_from( lastc, [:n,:s] ) { |p| p == lastp } == 2 ||
      board.each_from( lastc, [:ne,:sw] ) { |p| p == lastp } == 2 ||
      board.each_from( lastc, [:nw,:se] ) { |p| p == lastp } == 2
    end

    def winner?( player )
      final? && !draw? && lastp == player
    end

    def loser?( player )
      final? && !draw? && lastp != player
    end

    def draw?
      board.unoccupied.empty? &&
      board.each_from( lastc, [:e,:w] ) { |p| p == lastp } != 2 &&
      board.each_from( lastc, [:n,:s] ) { |p| p == lastp } != 2 &&
      board.each_from( lastc, [:ne,:sw] ) { |p| p == lastp } != 2 &&
      board.each_from( lastc, [:nw,:se] ) { |p| p == lastp } != 2
    end

    def hash
      [board, turn].hash
    end
  end

end

