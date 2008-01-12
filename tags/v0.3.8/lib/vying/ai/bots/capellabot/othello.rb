# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying/ai/bot'
require 'vying/ai/search'
require 'vying/ai/strategies/othello/othello'

class CapellaBot < Bot
  class Othello < Bot
    include AlphaBeta
    include OthelloStrategies

    difficulty :easy

    attr_reader :leaf, :nodes

    def initialize
      super
      @leaf, @nodes = 0, 0
      load_openings
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
 
      score 
    end

    def cutoff( position, depth )
      position.final? || depth >= 2
    end

  end
end

