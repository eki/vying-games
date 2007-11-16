require 'vying/ai/bot'
require 'vying/ai/search'
require 'vying/ai/strategies/keryo_pente/keryo_pente'

class CapellaBot < Bot
  class KeryoPente < Bot
    include AlphaBeta
    include KeryoPenteStrategies

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

      eval_threats( position, player )
    end

    def prune( position, player, moves )
      if position.board.threats.length > 0
         original_moves = moves
         threats = position.board.threats.sort_by { |t| t.degree }

         important = threats.select { |t| t.degree == 1 }
         unless important.empty?
           moves = important.map { |t| t.empty_coords.map { |c| c.to_s } }
           moves.flatten!

           return moves & original_moves
         else
           threats2 = threats.select { |t| t.player == player }
  
           unless threats2.empty?
             moves = threats2.map { |t| t.empty_coords.map { |c| c.to_s } }
             moves.flatten!
             moves = moves.sort_by do |move| 
               moves.select { |m| m == move }.length
             end
             moves = moves.uniq.reverse![0..2]

             return moves & original_moves
           else
             moves = threats.map { |t| t.empty_coords.map { |c| c.to_s } }
             moves.flatten!
             moves = moves.sort_by do |move|
               moves.select { |m| m == move }.length
             end
             moves = moves.uniq.reverse![0..5]

             return moves & original_moves
           end
         end
      else
        return super( position, player, moves )[0..1]
      end
    end

    def cutoff( position, depth )
      position.final? || depth >= 2
    end

  end
end

