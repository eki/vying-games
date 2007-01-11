require 'vying/ai/bot'
require 'vying/ai/search'
require 'vying/ai/bots/othello/othello'

class AI::Othello::MobilityBot < Bot
  include AI::Othello::Bot

  def eval( position, player )
    eval_frontier( position, player )
  end
end

