require 'vying/ai/bot'
require 'vying/ai/search'
require 'vying/ai/bots/othello/othello'

class AI::Othello::CharitableBot < Bot
  include AI::Othello::Bot

  def eval( position, player )
    oc, pc, total, score = eval_count( position, player )
    -score
  end
end

