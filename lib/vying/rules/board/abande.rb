# frozen_string_literal: true

# Copyright 2008, Eric Idema, Dieter Stein except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

# Abande
#
# For detailed rules see:  http://vying.org/games/abande
# or the official Abande site: http://abande.com

Rules.create('Abande') do
  name     'Abande'
  version  '1.0.0'
  notation :abande_notation

  players :black, :white

  highest_score_determines_winner

  cache :moves

  position do
    attr_reader :board, :pool, :pass

    def init
      @board = Board.hexagon(4, plugins: [:stacking])
      @pool  = Hash.new(18)
      @pass  = Hash.new(false)
    end

    def has_moves
      return []      if pass[:white] && pass[:black]
      return [turn]  if pool[turn] > 0
      return [turn]  if capture_moves.any?

      []
    end

    def moves
      all = []
      all += pool[turn] > 0 ? placement_moves : [:pass]
      all + capture_moves
    end

    def apply!(move)
      if move.to_s == 'pass'
        pass[turn] = true
      else
        coords = move.to_coords
        if coords.length == 1
          board[coords.first] = [turn]
          pool[turn] -= 1
        else
          board[coords.last] = board[coords.first] + board[coords.last]
          board[coords.first] = nil
        end
        pass.clear
      end
      rotate_turn
      self
    end

    def final?
      has_moves.empty?
    end

    def score(player)
      count = 0
      board.occupied.each do |c|
        next if board[c].nil?

        count += board[c].length if board[c].first == player && !sleeping?(c)
      end
      count
    end

    private

    def placement_moves
      all = []
      if turn == :black && pool[:black] == 18
        all += board.unoccupied
      else
        board.unoccupied.each do |c|
          all << c if board.coords.connected?(board.occupied + [c])
        end
      end

      all
    end

    def capture_moves
      all = []
      unless turn == :black && pool[:black] == 17
        board.pieces.each do |p|
          next unless p && p.first == turn

          board.occupied(p).each do |c|
            board.coords.neighbors(c).each do |n|
              if board[n] && board[n].first == opponent(turn) && board[c].length + board[n].length <= 3
                all << "#{c}#{n}" if board.coords.connected?(board.occupied - [c])
              end
            end
          end
        end
      end

      all
    end

    def sleeping?(coord)
      player = opponent(board[coord].first)

      board.coords.neighbors(coord).each do |c|
        return false if board[c] && board[c].first == player
      end
      true
    end
  end
end
