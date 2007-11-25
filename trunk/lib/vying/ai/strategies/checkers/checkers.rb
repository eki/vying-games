# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

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

