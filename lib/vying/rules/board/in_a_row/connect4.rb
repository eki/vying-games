# frozen_string_literal: true

# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

Rules.create('Connect4') do
  name    'Connect Four'
  version '1.0.0'

  players :red, :blue

  init_moves(Coords.new(Coords.bounds_for(7, 6)).group_by(&:x).
     map { |sa| sa.map(&:to_s) })

  position do
    attr_reader :board, :unused_moves
    ignore :unused_moves

    def init
      @board = Board.rect(7, 6, plugins: [:in_a_row])

      @board.window_size = 4
      @unused_moves = rules.init_moves.map(&:dup)
    end

    def moves
      return [] if final?
      unused_moves.map(&:last)
    end

    def apply!(move)
      board[move] = turn
      unused_moves.each { |a| a.delete(move.to_s) }
      unused_moves.delete([])
      rotate_turn
      self
    end

    def final?
      board.unoccupied.empty? || board.threats.any? { |t| t.degree == 0 }
    end

    def winner?(player)
      board.threats.any? { |t| t.degree == 0 && t.player == player }
    end

    def draw?
      board.unoccupied.empty? && board.threats.none? { |t| t.degree == 0 }
    end
  end
end
