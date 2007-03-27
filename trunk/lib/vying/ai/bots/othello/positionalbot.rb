require 'vying/ai/bot'
require 'vying/ai/search'
require 'vying/ai/bots/othello/othello'

class AI::Othello::PositionalBot < AI::Bot
  include AI::Othello::Bot

  def eval( position, player )
    pc, oc, total, score = eval_count( position, player )

    return eval_board_early( position, player ) if total <= 20
    return eval_board_late(  position, player ) if total > 20
  end
end

