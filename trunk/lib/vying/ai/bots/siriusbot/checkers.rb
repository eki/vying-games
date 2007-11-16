require 'vying/ai/bot'
require 'vying/ai/search'
require 'vying/ai/strategies/checkers/checkers'

class SiriusBot < Bot
  class Checkers < Bot
    include AlphaBeta
    include CheckersStrategies

    difficulty :hard

    attr_reader :leaf, :nodes

    def initialize
      super
      @leaf, @nodes = 0, 0
      load_openings
    end

    def select( sequence, position, player )
      return position.moves.first if position.moves.length == 1

      @leaf, @nodes = 0, 0
      score, move = fuzzy_best( analyze( position, player ), 1 )
      puts "**** Searched #{nodes}:#{leaf} positions, best: #{score}"
      move
    end

    def accept_draw?( sequence, position, player )
      position.board.occupied[player].length < 3
    end

    def evaluate( position, player )
      @leaf += 1

      return  1000 if position.final? && position.winner?( player )
      return -1000 if position.final? && position.loser?( player )
      return     0 if position.final?
    
      eval_captures( position, player )
    end

    def cutoff( position, depth )
      position.final? || depth >= 3
    end

  end
end

