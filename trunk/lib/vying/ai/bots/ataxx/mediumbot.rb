require 'vying/ai/bot'
require 'vying/ai/bots/ataxx/ataxx'

class AI::Ataxx::MediumBot < AI::Bot
  include AI::Ataxx::Bot

  def eval( position, player )
    eval_score( position, player )
  end

  def cutoff( position, depth )
    if position.board.empty_count < 2
      position.final? || depth >= 3
    elsif position.board.empty_count < 8
      position.final? || depth >= 2
    else
      position.final? || depth >= 1
    end
  end
end

