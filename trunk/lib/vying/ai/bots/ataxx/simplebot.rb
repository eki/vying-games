require 'vying/ai/bot'
require 'vying/ai/bots/ataxx/ataxx'

class AI::Ataxx::SimpleBot < AI::Bot
  include AI::Ataxx::Bot

  def eval( position, player )
    eval_score( position, player )
  end

  def cutoff( position, depth )
    position.final? || depth >= 0
  end
end

