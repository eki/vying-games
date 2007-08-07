require 'vying/ai/bot'
require 'vying/ai/bots/keryo_pente/keryo_pente'

class AI::KeryoPente::ThreatsBot < AI::Bot
  include AI::KeryoPente::Bot

  def eval( position, player )
    eval_random( position, player )
  end

  def prune( position, player, ops )
    if position.board.threats.length > 0
       original_ops = ops
       threats = position.board.threats.sort_by { |t| t.degree }

       if threats.first.degree < 3
         return threats.first.empty_coords.map { |c| c.to_s }
       else
         ops = threats.map { |t| t.empty_coords.map { |c| c.to_s } }
         ops.flatten!
         ops = ops.sort_by { |op| ops.select { |o| o == op }.length }
         ops = ops.uniq.reverse![0..2]

         return ops & original_ops
       end
    else
      return super( position, player, ops )[0..2]
    end
  end

  def cutoff( position, depth )
    position.final? || depth >= 4
  end
end

