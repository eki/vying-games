# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying/ai/bot'
require 'vying/ai/search'
require 'vying/ai/strategies/nine_mens_morris/nine_mens_morris'

class SiriusBot < Bot
  class NineMensMorris < Bot
    include AlphaBeta
    include NineMensMorrisStrategies

    difficulty :hard

    attr_reader :leaf, :nodes

    def initialize( *args )
      super
      @leaf, @nodes = 0, 0
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
    
      eval_score( position, player ) +
      eval_mills( position, player ) +
      eval_mobility( position, player )
    end

    def cutoff( position, depth )
      return true if position.final?

      if position.moves.length < 2
        depth >= 5
      elsif position.moves.length < 4
        depth >= 4
      elsif position.moves.length > 12
        depth >= 1
      else
        depth >= 2
      end
    end

  end
end

