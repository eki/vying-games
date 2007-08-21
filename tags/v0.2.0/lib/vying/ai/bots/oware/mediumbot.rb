require 'vying/ai/bot'
require 'vying/ai/bots/oware/oware'

class AI::Oware::MediumBot < AI::Bot
  include AI::Oware::Bot

  def eval( position, player )
    eval_score( position, player )
  end

  def cutoff( position, depth )
    position.final? || depth >= 2
  end
end

