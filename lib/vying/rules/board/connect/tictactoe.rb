# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

Rules.create( "TicTacToe" ) do
  name    "Tic Tac Toe"
  version "1.0.0"

  players :x, :o

  position do
    attr_reader :board
  
    def init
      @board = Board.square( 3, :plugins => [:in_a_row] )
      @board.window_size = 3
    end

    def moves
      final? ? [] : board.unoccupied
    end

    def apply!( move )
      board[move] = turn
      rotate_turn
      self
    end

    def final?
      board.unoccupied.empty? || board.threats.any? { |t| t.degree == 0 }
    end

    def winner?( player )
      board.threats.any? { |t| t.degree == 0 && t.player == player }
    end

    def loser?( player )
      winner?( opponent( player ) )
    end

    def draw?
      board.unoccupied.empty? && ! board.threats.any? { |t| t.degree == 0 }
    end

    def hash
      [board, turn].hash
    end
  end

end

