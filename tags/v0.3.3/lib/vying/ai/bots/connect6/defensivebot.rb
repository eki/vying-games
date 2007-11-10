require 'vying/ai/bot'
require 'vying/ai/bots/connect6/connect6'

class AI::Connect6::DefensiveBot < AI::Bot
  include AI::Connect6::Bot

  def eval( position, player )
    eval_threats( position, player )
  end

  def prune( position, player, moves )
    if position.board.threats.length > 0
       original_moves = moves
       threats = position.board.threats.sort_by { |t| t.degree }

       if threats.first.degree < 3
         return threats.first.empty_coords.map { |c| c.to_s }
       else
         threats2 = threats.select { |t| t.player != player && t.degree < 4 }

         unless threats2.empty?
           moves = threats2.map { |t| t.empty_coords.map { |c| c.to_s } }
           moves.flatten!
           moves = moves.sort_by do |move| 
             moves.select { |m| m == move }.length
           end
           moves = moves.uniq.reverse![0..1]

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
    position.final? || depth >= 0
  end
end

