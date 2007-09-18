require 'vying/ai/bot'
require 'vying/ai/bots/breakthrough/breakthrough'

class AI::Breakthrough::DeepBot < AI::Bot
  include AI::Breakthrough::Bot

  def eval( position, player )
    0.5 * eval_distance( position, player ) +
    3 * eval_most_advanced( position, player ) +
    eval_captures( position, player )
  end

end

