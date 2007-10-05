require 'vying/ai/bot'
require 'vying/ai/bots/keryo_pente/keryo_pente'

class AI::KeryoPente::ThreatsBot < AI::Bot
  include AI::KeryoPente::Bot

  def eval( position, player )
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
         moves = moves.sort_by { |move| moves.select { |m| m == move }.length }
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

