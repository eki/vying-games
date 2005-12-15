$:.unshift File.join( File.dirname( __FILE__ ), ".." )

require 'game'
require 'search'

class ExhaustiveBot

  def ExhaustiveBot.select( game )
    ops = game.ops
    minimax = Minimax.new( game.rules )

    best_score = nil
    best_op = nil

    ops.each do |op| 
      score = minimax.search( op.call, game.history.last.turn.current, 1 )

      best_score ||= score
      best_op ||= op

      best_score, best_op = score, op if score > best_score
    end
    best_op
  end

end

