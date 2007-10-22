require 'vying/ai/bot'
require 'vying/ai/bots/amazons/amazons'

class AI::Amazons::NeighborsBot < AI::Bot
  include AI::Amazons::Bot

  def eval( position, player )
    eval_neighbors( position, player )
  end
end

