require 'vying/ai/bot'
require 'vying/ai/search'
require 'vying/ai/bots/othello/othello'

class AI::Othello::ComboBot < Bot
  include AI::Othello::Bot

  def initialize
    super
    load_corners
  end

  def eval( position, player )
    total = position.occupied.length

    eval_frontier( position, player ) +
    position.ops.length +
    eval_corners( position, player )
  end

  def cutoff( position, depth )
    return true if position.final?

    total = position.board.count( :black ) + 
            position.board.count( :white )

    if( total - depth < 44 )
      return true if depth >= 2
    end

    if( total - depth < 54 )
      return true if depth >= 3
    end

    if( total - depth < 56 )
      return true if depth >= 4
    end

    return false
  end

end

