require 'vying/ai/bot'
require 'vying/ai/search'
require 'vying/ai/strategies/pente/pente'

class SiriusBot < Bot
  class Pente < Bot
    include AlphaBeta
    include PenteStrategies

    difficulty :easy

    attr_reader :leaf, :nodes

    def initialize
      super
      @leaf, @nodes = 0, 0
    end

    def select( sequence, position, player )
      return position.moves.first if position.moves.length == 1

      @leaf, @nodes = 0, 0
      score, move = fuzzy_best( analyze( position, player ), 1 )
      puts "**** Searched #{nodes}:#{leaf} positions, best: #{score}"
      move
    end

    def evaluate( position, player )
      @leaf += 1

      return  1000 if position.final? && position.winner?( player )
      return -1000 if position.final? && position.loser?( player )
      return     0 if position.final?

      eval_random( position, player )
    end

    def prune( position, player, moves )
      if position.board.threats.length > 0
         original_moves = moves
         threats = position.board.threats.sort_by { |t| t.degree }

         if threats.first.degree < 3
           return threats.first.empty_coords.map { |c| c.to_s }
         else
           moves = threats.map { |t| t.empty_coords.map { |c| c.to_s } }
           moves.flatten!
           moves = 
             moves.sort_by { |move| moves.select { |m| m == move }.length }
           moves = moves.uniq.reverse![0..2]
  
           return moves & original_moves
         end
      else
        return super( position, player, moves )[0..2]
      end
    end

    def cutoff( position, depth )
      position.final? || depth >= 4
    end

  end
end

