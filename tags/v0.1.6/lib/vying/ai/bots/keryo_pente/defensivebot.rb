require 'vying/ai/bot'
require 'vying/ai/bots/keryo_pente/keryo_pente'

class AI::KeryoPente::DefensiveBot < AI::Bot
  include AI::KeryoPente::Bot

  def eval( position, player )
    eval_score( position, player ) * 10 + eval_threats2( position, player )
  end

  def prune( position, player, ops )
    n = (position.board.occupied[:white] || []).length < 30 ? super : nil

    return n if n

    if position.board.threats.length > 0
       original_ops = ops
       threats = position.board.threats.sort_by { |t| t.degree }

       if threats.first.degree == 1
         return threats.first.empty_coords.map { |c| c.to_s }
       else
         threats2 = threats.select do |t|
           (t.player != player && t.degree == 3) || t.degree < 3
         end

         unless threats2.empty?
           ops = threats2.map { |t| t.empty_coords.map { |c| c.to_s } }
           ops.flatten!
           ops = ops.sort_by { |op| ops.select { |o| o == op }.length }
           ops = ops.uniq.reverse![0..5]

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
    position.final? || depth >= 0
  end
end

