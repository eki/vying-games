require 'vying/ai/bot'
require 'vying/ai/bots/pente/pente'

class AI::Pente::AggressiveBot < AI::Bot
  include AI::Pente::Bot

  def eval( position, player )
    eval_threats( position, player )
  end

  def prune( position, player, ops )
    if position.board.threats.length > 0
       original_ops = ops
       threats = position.board.threats.sort_by { |t| t.degree }

       important = threats.select { |t| t.degree == 1 }
       unless important.empty?
         ops = important.map { |t| t.empty_coords.map { |c| c.to_s } }
         ops.flatten!

         return ops & original_ops
       else
         threats2 = threats.select { |t| t.player == player }

         unless threats2.empty?
           ops = threats2.map { |t| t.empty_coords.map { |c| c.to_s } }
           ops.flatten!
           ops = ops.sort_by { |op| ops.select { |o| o == op }.length }
           ops = ops.uniq.reverse![0..2]

           return ops & original_ops
         else
           ops = threats.map { |t| t.empty_coords.map { |c| c.to_s } }
           ops.flatten!
           ops = ops.sort_by { |op| ops.select { |o| o == op }.length }
           ops = ops.uniq.reverse![0..5]

           return ops & original_ops
         end
       end
    else
      return super( position, player, ops )[0..1]
    end
  end

  def cutoff( position, depth )
    position.final? || depth >= 2
  end
end

