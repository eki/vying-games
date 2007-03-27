require 'vying/ai/bot'
require 'vying/ai/bots/connect6/connect6'

class AI::Connect6::ThreatsBot < AI::Bot
  include AI::Connect6::Bot

  def eval( position, player )
    eval_threats( position, player )
  end

  def prune( position, ops )
    if position.board.threats.length > 0
       original_ops = ops
       threats = position.board.threats.sort_by { |t| t.degree }
#      ops = threats.map { |t| t.empty_coords.map { |c| c.to_s } }
#      ops.flatten!.uniq!
#      return ops[0..4]

       if threats.first.degree == 0
         puts "First threat is degree 0, is position final? #{position.final?}"
         puts "#{position.board}"
         puts "#{threats.first.inspect}"
         return original_ops[rand(original_ops.length)]
       elsif threats.first.degree < 3
         return threats.first.empty_coords.map { |c| c.to_s }
       else
         ops = threats.map { |t| t.empty_coords.map { |c| c.to_s } }
         ops.flatten!
         ops.sort_by { |op| ops.select { |o| o == op }.length }
         ops = ops.uniq.reverse![0..4]

         if ops.class != Array
           puts "ops not an array: #{ops.inspect} #{ops.class}"
         elsif ops & original_ops != ops
           puts "ops mistakenly contains: #{(ops - original_ops).inspect}"
         end

         return ops & original_ops
       end
       
      
    else
      return super( position, ops )[0..4]
    end
  end

  def cutoff( position, depth )
    position.final? || depth >= 4
  end
end

