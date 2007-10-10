require 'vying/ai/bot'

module AI::Kalah

  def eval_score( position, player )
    opp = player == :one ? :two : :one

    position.score( player ) - position.score( opp )
  end

  module Bot
    include AI::Kalah
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
      position.final? || depth >= 4
    end
  end
end

