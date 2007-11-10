require 'vying/ai/bot'
require 'vying/ai/bots/checkers/checkers'

class AI::Checkers::SimpleBot < AI::Bot
  include AI::Checkers::Bot

  def eval( position, player )
    eval_captures( position, player )
  end

  def cutoff( position, depth )
    position.final? || depth >= 1
  end

end

