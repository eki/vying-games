require 'vying/ai/bot'
require 'vying/ai/search'
require 'vying/ai/bots/othello/othello'

class AI::Othello::EdgeBot < AI::Bot
  include AI::Othello::Bot

  def initialize
    super
    load_corners
    load_edges
  end

  def eval( position, player )
    eval_corners( position, player ) +
    eval_edges( position, player )
  end
end

