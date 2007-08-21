require 'vying/ai/bot'
require 'vying/ai/bots/phutball/phutball'

class AI::Phutball::AggressiveBot < AI::Bot
  include AI::Phutball::Bot

  def eval( position, player )
    eval_distance( position, player ) * 100 + eval_men( position, player )
  end

  def cutoff( position, depth )
    position.final? || depth >= 1
  end
end

