# frozen_string_literal: true

# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

Rules.create('KeryoPente') do
  name    'Keryo-Pente'
  version '1.0.0'

  players :white, :black

  cache :moves

  position do
    attr_reader :board, :captured

    def init
      @board = Board.square(19, plugins: [:in_a_row, :custodial_capture])

      @board.window_size = 5
      @captured = { black: 0, white: 0 }
    end

    def moves
      final? ? [] : board.unoccupied
    end

    def apply!(move)
      cc = board.custodial_capture(Coord[move], turn, 2..3)
      captured[turn] += cc.length
      rotate_turn
      self
    end

    def final?
      board.unoccupied.empty? || captured.any? { |p, t| t >= 15 } ||
      board.threats.any? { |t| t.degree == 0 }
    end

    def winner?(player)
      captured[player] >= 15 ||
      board.threats.any? { |t| t.degree == 0 && t.player == player }
    end

    def draw?
      board.unoccupied.empty? && captured.none? { |p, t| t >= 15 } &&
      board.threats.none? { |t| t.degree == 0 }
    end

    def score(player)
      captured[player]
    end
  end
end
