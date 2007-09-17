require 'vying/ai/bot'
require 'vying/ai/bots/nine_mens_morris/nine_mens_morris'

class AI::NineMensMorris::SimpleBot < AI::Bot
  include AI::NineMensMorris::Bot

  def eval( position, player )
    eval_score( position, player )
  end

  def cutoff( position, depth )
    position.final? || depth >= 0
  end
end

