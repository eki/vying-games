require 'vying/ai/bot'
require 'vying/ai/bots/ataxx/ataxx'

class AI::Ataxx::DeepBot < AI::Bot
  include AI::Ataxx::Bot

  def eval( position, player )
    eval_score( position, player )
  end

  def cutoff( position, depth )
    position.final? || depth >= 2
  end
end

