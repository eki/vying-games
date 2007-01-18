require 'vying/ai/bot'
require 'vying/ai/search'
require 'vying/ai/bots/othello/othello'

class AI::Othello::ComboBot < Bot
  include AI::Othello::Bot

  def initialize
    super
    load_corners
    load_edges
  end

  def eval( position, player )
    total = position.occupied.length

    if( total < 35 )
      eval_frontier( position, player ) * 3 +
      eval_corners( position, player ) +
      eval_edges( position, player )
    else
      eval_corners( position, player ) +
      eval_edges( position, player )
    end

  end

  def cutoff( position, depth )
    return true if position.final?

    total = position.occupied.length 

    if( total - depth < 54 )
      return true if depth >= 3
    end

    return false
  end

end

