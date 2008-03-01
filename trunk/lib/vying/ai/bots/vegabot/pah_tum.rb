# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying/ai/bot'
require 'vying/ai/search'
require 'vying/ai/strategies/pah_tum/pah_tum'

class VegaBot < Bot
  class PahTum < Bot
    include AlphaBeta
    include PahTumStrategies

    difficulty :easy

    attr_reader :leaf, :nodes

    def initialize( *args )
      super
      @leaf, @nodes = 0, 0
    end

    def select( sequence, position, player )
      return position.moves.first if position.moves.length == 1

      @leaf, @nodes = 0, 0
      score, move = fuzzy_best( analyze( position, player ), 0 )
      puts "**** Searched #{nodes}:#{leaf} positions, best: #{score}"
      move
    end

    def evaluate( position, player )
      @leaf += 1

      return  1000 if position.final? && position.winner?( player )
      return -1000 if position.final? && position.loser?( player )
      return     0 if position.final?
  
      eval_neighbors( position, player ) + 
      eval_defense( position, player ) +
      eval_score( position, player )
    end

    def cutoff( position, depth )
      return true if position.final?

      case position.board.empty_count
        when 1..4
          depth >= 4
        when 5..7
          depth >= 3
        when 8..10
          depth >= 2
        else
          depth >= 1
      end
    end

  end
end

