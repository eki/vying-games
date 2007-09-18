require 'vying/ai/bot'
require 'vying/ai/bots/breakthrough/breakthrough'

class AI::Breakthrough::DeepBot < AI::Bot
  include AI::Breakthrough::Bot

  def eval( position, player )
    eval_distance( position, player ) +
    eval_most_advanced( position, player ) +
    eval_captures( position, player )
  end

end

