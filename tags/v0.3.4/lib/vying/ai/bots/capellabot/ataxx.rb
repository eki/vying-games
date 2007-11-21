require 'vying/ai/bot'
require 'vying/ai/search'
require 'vying/ai/strategies/ataxx/ataxx'

class CapellaBot < Bot
  class Ataxx < Bot
    include AlphaBeta
    include AtaxxStrategies

    difficulty :easy

    attr_reader :leaf, :nodes

    def initialize
      super
      @leaf, @nodes = 0, 0
    end

    def select( sequence, position, player )
      return position.moves.first if position.moves.length == 1

      t = position.turn
      p = position.apply( position.moves.first )
      return position.moves.first if p.turn == t

      @leaf, @nodes = 0, 0
      score, move = fuzzy_best( analyze( position, player ), 0 )
      puts "**** Searched #{nodes}:#{leaf} positions, best: #{score}"
      move
    end

    def evaluate( position, player )
      @leaf += 1

      return  1000 if position.final? && position.winner?( player )
      return -1000 if position.final? && position.loser?( player )
      return     0 if position.final?

      eval_score( position, player )
    end

    def cutoff( position, depth )
      position.final? || depth >= 0
    end

    def prune( position, player, moves )
      jumps = []
      splits = {}

      moves.each do |m|
        coords = m.to_coords

        dx = (coords.first.x - coords.last.x).abs
        dy = (coords.first.y - coords.last.y).abs

        if dx <= 1 && dy <= 1 && (dx == 1 || dy == 1)
          splits[coords.last] = m
        else
          jumps << m
        end
      end

      splits.values + jumps
    end

  end
end

