# Copyright 2008, Eric Idema, Dieter Stein except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

# Abande
#
# For detailed rules see:  http://vying.org/games/abande
# or the official Abande site: http://abande.com

Rules.create( 'Abande' ) do
  name     'Abande'
  version  '0.1.0'
#  notation :abande_notation

  players :black, :white

  score_determines_outcome

  cache :moves

  position do
    attr_reader :board, :pool, :pass

    def init
      @board = Board.hexagon( 4, :plugins => [:stacking] )
      @pool = { :white => 18, :black => 18 }
      @pass = { :white => false, :black => false }
      @moves = { :white => 0, :black => 0 }
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
      all += capture_moves
    end

    def apply!( move )
      unless pass[turn] = move == :pass
        coords = move.to_coords
        if coords.length == 1
          board[coords.first] = [turn]
          pool[turn] -= 1
        else
          board[coords.last] = board[coords.first] + board[coords.last]
          board[coords.first] = nil
        end
      end
      @moves[turn] += 1
      rotate_turn
      self
    end

    def final?
      has_moves.empty?
    end

    def score( player )
      count = 0
      board.pieces.each do |p|
        cs = board.occupied( p )

        next if cs.nil?
        count += cs.length if p.first == player # TODO: && adjacent to enemy!
      end
      count
    end

    def hash
      [board, pool, pass, turn].hash
    end

    private

    def placement_moves
      if turn == :black && @moves[:black] == 0
        board.unoccupied
      else
        board.unoccupied # FIXME: adjacent placements only!
      end
    end

    def capture_moves
      all = []
      unless turn == :black && @moves[:black] == 1
        board.pieces.each do |p|
          if p && p.first == turn
            # TODO: moves which preserve connectivity
          end
        end
      end

      all
    end

  end
end

