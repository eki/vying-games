require 'vying/ai/bot'
require 'vying/ai/bots/connect6/connect6'

class AI::Connect6::AggressiveBot < AI::Bot
  include AI::Connect6::Bot

  def eval( position, player )
    eval_player_threats( position, player )
  end

  def prune( position, player, ops )
    n = (position.board.occupied[:white] || []).length < 20 ? super : nil

    if position.board.threats.length > 0
       original_ops = ops
       threats = position.board.threats.sort_by { |t| t.degree }

       important = []
       p_important = threats.select { |t| t.degree < 3 && t.player == player }
       o_important = threats.select { |t| t.degree < 3 && t.player != player }

       threes = threats.select { |t| t.degree == 3 && t.player == player }
       twos   = threats.select { |t| t.degree == 4 && t.player == player }

       ops3 = threes.map { |t| t.empty_coords.map { |c| c.to_s } }
       ops3.flatten!

       ops2 = twos.map { |t| t.empty_coords.map { |c| c.to_s } }
       ops2.flatten!

       important += p_important[0..1]
       important += o_important[0..1]

       unless important.empty?
         ops = important.map { |t| t.empty_coords.map { |c| c.to_s } }
         ops.flatten!
         ops  &= n if n
         ops3 &= n if n
         ops2 &= n if n

         ops3 -= ops
         ops2 -= ops

         ops << ops3[rand(ops3.length)] unless ops3.empty?
         ops << ops2[rand(ops2.length)] unless ops2.empty?
         ops << n.find { |o| !ops.include?( o ) } if n

         return ops 
       else
         threats2 = threats.select { |t| t.player == player }

         unless threats2.empty?
           ops = threats2.map { |t| t.empty_coords.map { |c| c.to_s } }
           ops.flatten!
           ops = ops.sort_by { |op| ops.select { |o| o == op }.length }
           ops = ops.uniq.reverse!

           ops  &= n if n
           ops3 &= n if n
           ops2 &= n if n

           ops = ops[0..2]

           ops3 -= ops
           ops2 -= ops

           ops << ops3[rand(ops3.length)] unless ops3.empty?
           ops << ops2[rand(ops2.length)] unless ops2.empty?
           ops << n.find { |o| !ops.include?( o ) } if n

           return ops
         else
           ops = threats.map { |t| t.empty_coords.map { |c| c.to_s } }
           ops.flatten!
           ops = ops.sort_by { |op| ops.select { |o| o == op }.length }
           ops = ops.uniq.reverse!

           if n
             ops &= n
           else
             nops = ops.select { |op| position.board.has_neighbor? op }
             ops = nops unless nops.empty?
           end

           return ops[0..3]
         end
       end
    else
      return n.sort_by { rand }[0..2] if n
      return ops.sort_by { rand }[0..2]
    end
  end

  def cutoff( position, depth )
    position.final? || depth >= 2
  end
end

