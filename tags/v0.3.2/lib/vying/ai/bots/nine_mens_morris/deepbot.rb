require 'vying/ai/bot'
require 'vying/ai/bots/nine_mens_morris/nine_mens_morris'

class AI::NineMensMorris::DeepBot < AI::Bot
  include AI::NineMensMorris::Bot

  def eval( position, player )
    eval_score( position, player ) +
    eval_mills( position, player ) +
    eval_mobility( position, player )
  end

  def cutoff( position, depth )
    return true if position.final?

    if position.moves.length < 2
      depth >= 5
    elsif position.moves.length < 4
      depth >= 4
    elsif position.moves.length > 12
      depth >= 1
    else
      depth >= 2
    end
  end
end

