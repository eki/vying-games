require 'vying/ai/bot'

module AI::Checkers

  def eval_captures( position, player )
    opp  = player == :red ? :white : :red
    k    = player == :red ? :RED : :WHITE
    oppk = player == :red ? :WHITE : :RED
    b = position.board

    (b.occupied[player].length - b.occupied[opp].length) * 2 +
    ((b.occupied[k] || []).length - (b.occupied[oppk] || []).length) * 5
  end

  module Bot
    include AI::Checkers
    include AlphaBeta

    attr_reader :nodes, :leaf

    def initialize
      super
    end

    def select( sequence, position, player )
      return position.moves.first if position.moves.length == 1

      @leaf, @nodes = 0, 0
      score, move = fuzzy_best( analyze( position, player ), 1 )
      puts "**** Searched #{nodes}:#{leaf} positions, best: #{score}"

      move
    end

    def evaluate( position, player )
      @leaf += 1

      return  1000 if position.final? && position.winner?( player )
      return -1000 if position.final? && position.loser?( player )
      return     0 if position.final?

      eval( position, player )
    end

    def cutoff( position, depth )
      position.final? || depth >= 2
    end
  end
end

