# frozen_string_literal: true

# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying/games'

# Amazons is a territory game.  With every move the playable area of the
# game board is reduced.  Each player tries to claim more territory so they
# can outlast their opponent.
#
# For detailed rules see:  http://vying.org/games/amazons

Rules.create('Amazons') do
  name    'Amazons'
  version '1.0.0'

  players :white, :black

  position do
    attr_reader :board, :lastc

    def init
      @board = Board.square(10, plugins: [:amazons])

      @board[:a4, :d1, :g1, :j4] = :white
      @board[:a7, :g10, :d10, :j7] = :black

      @lastc = nil
    end

    def move?(move)
      cs = move.to_coords
      return false unless cs.length == 2

      queens = board.occupied(turn)

      return false unless queens.include?(cs.first)
      return false unless d = cs.first.direction_to(cs.last)

      ic = cs.first
      while (ic = board.coords.next(ic, d))
        return false unless board[ic].nil?
        break        if ic == cs.last
      end

      true
    end

    def has_moves
      queens = board.occupied(turn)
      queens.any? { |q| !board.mobility[q].empty? } ? [turn] : []
    end

    def moves
      a = []

      queens = board.occupied(turn)

      if lastc.nil? || board[lastc] == :arrow
        queens.each do |q|
          board.mobility[q].each { |ec| a << "#{q}#{ec}" }
        end
      else
        board.mobility[lastc].each { |ec| a << "#{lastc}#{ec}" }
      end

      a
    end

    def apply!(move)
      coords = move.to_coords

      if lastc.nil? || board[lastc] == :arrow
        board.move(coords.first, coords.last)
      else
        board.arrow(coords.last)
        rotate_turn
      end

      @lastc = coords.last

      self
    end

    def final?
      has_moves.empty?
    end

    def winner?(player)
      player != turn
    end

    def score(player)
      board.territory(player).length
    end
  end
end
