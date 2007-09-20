require 'vying/ai/bot'
require 'vying/ai/bots/breakthrough/breakthrough'

class AI::Breakthrough::SimpleBot < AI::Bot
  include AI::Breakthrough::Bot

  def eval( position, player )
    eval_captures( position, player )
  end

end

