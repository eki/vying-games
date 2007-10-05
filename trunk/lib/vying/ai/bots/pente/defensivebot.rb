require 'vying/ai/bot'
require 'vying/ai/bots/pente/pente'

class AI::Pente::DefensiveBot < AI::Bot
  include AI::Pente::Bot

  def eval( position, player )
    eval_score( position, player ) * 10 + eval_threats2( position, player )
  end

  def prune( position, player, moves )
    n = (position.board.occupied[:white] || []).length < 30 ? super : nil

    return n if n

    if position.board.threats.length > 0
       original_moves = moves
       threats = position.board.threats.sort_by { |t| t.degree }

       if threats.first.degree == 1
         return threats.first.empty_coords.map { |c| c.to_s }
       else
         threats2 = threats.select do |t|
           (t.player != player && t.degree == 3) || t.degree < 3
         end

         unless threats2.empty?
           moves = threats2.map { |t| t.empty_coords.map { |c| c.to_s } }
           moves.flatten!
           moves = moves.sort_by do |move| 
             moves.select { |m| m == move }.length
           end
           moves = moves.uniq.reverse![0..5]

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

