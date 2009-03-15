# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

Vying.rules( "Connect6" ) do
  name    "Connect6"
  version "1.0.0"

  players :black, :white

  allow_draws_by_agreement

  cache :moves

  position do
    attr_reader :board

    def init
      @board = Board.square( 19, :plugins => [:in_a_row] )

      @board.window_size = 6
      @turn = [:black, :white, :white, :black]
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

    def draw?
      board.unoccupied.empty? && ! board.threats.any? { |t| t.degree == 0 }
    end
  end

end

