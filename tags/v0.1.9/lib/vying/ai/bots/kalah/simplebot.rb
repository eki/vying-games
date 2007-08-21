require 'vying/ai/bot'
require 'vying/ai/bots/kalah/kalah'

class AI::Kalah::SimpleBot < AI::Bot
  include AI::Kalah::Bot

  def eval( position, player )
    eval_score( position, player )
  end

  def cutoff( position, depth )
    position.final? || depth >= 0
  end
end

