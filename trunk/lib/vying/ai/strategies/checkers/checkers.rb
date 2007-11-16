require 'vying/ai/bot'

module CheckersStrategies

  def eval_captures( position, player )
    opp  = player == :red ? :white : :red
    k    = player == :red ? :RED : :WHITE
    oppk = player == :red ? :WHITE : :RED
    b = position.board

    (b.occupied[player].length - b.occupied[opp].length) * 2 +
    ((b.occupied[k] || []).length - (b.occupied[oppk] || []).length) * 5
  end

end

