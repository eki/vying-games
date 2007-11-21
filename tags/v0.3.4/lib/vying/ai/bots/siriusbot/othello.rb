require 'vying/ai/bot'
require 'vying/ai/search'
require 'vying/ai/strategies/othello/othello'

class SiriusBot < Bot
  class Othello < Bot
    include AlphaBeta
    include OthelloStrategies

    difficulty :hard

    attr_reader :leaf, :nodes

    def initialize
      super
      @leaf, @nodes = 0, 0
      load_openings
      load_corners
    end

    def select( sequence, position, player )
      return position.moves.first if position.moves.length == 1

      if( move = opening( position, sequence ) )
        puts "**** Taking opening #{sequence.join}:#{move}"
        return move
      end

      @leaf, @nodes = 0, 0
      score, move = best( analyze( position, player ) )
      puts "**** Searched #{nodes}:#{leaf} positions, best: #{score}"
      move
    end

    def evaluate( position, player )
      pc, oc, total, score = eval_count( position, player )

      return score * 1000 if position.final?

      eval_frontier( position, player ) +
      position.moves.length +
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
end

