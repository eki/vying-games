require 'vying/ai/bot'
require 'vying/ai/bots/breakthrough/breakthrough'

class AI::Breakthrough::MediumBot < AI::Bot
  include AI::Breakthrough::Bot

  def eval( position, player )
    eval_most_advanced( position, player )
  end

end

