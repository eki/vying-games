require 'vying/ai/bot'
require 'vying/ai/bots/amazons/amazons'

class AI::Amazons::ComboBot < AI::Bot
  include AI::Amazons::Bot

  def eval( position, player )
    ts = position.board.territories
    if ts.all? { |t| t.black.empty? && t.white.empty? }
      eval_score( position, player )
    else
      3 * eval_neighbors( position, player ) +
      10 * eval_territories( position, player ) +
      eval_centrality( position, player )
    end
  end
end

