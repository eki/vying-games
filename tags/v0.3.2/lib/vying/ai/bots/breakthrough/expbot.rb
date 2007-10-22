require 'vying/ai/bot'
require 'vying/ai/bots/breakthrough/breakthrough'

class AI::Breakthrough::ExpBot < AI::Bot
  include AI::Breakthrough::Bot

  def eval( position, player )
    eval_captures( position, player ) +
    30 * eval_clear_path( position, player )
  end

end

