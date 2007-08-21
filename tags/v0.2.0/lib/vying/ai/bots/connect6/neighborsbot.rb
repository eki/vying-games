require 'vying/ai/bot'
require 'vying/ai/bots/connect6/connect6'

class AI::Connect6::NeighborsBot < AI::Bot
  include AI::Connect6::Bot

  def eval( position, player )
    eval_neighbors( position, player )
  end
end

