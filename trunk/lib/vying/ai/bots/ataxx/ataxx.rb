require 'vying/ai/bot'

module AI::Ataxx

  def eval_score( position, player )
    opp = player == :red ? :blue : :red

    if position.board.count( player ) + position.board.count( opp ) < 10
      position.score( player )
    else
      position.score( player ) - position.score( opp )
    end
  end

  module Bot
    include AI::Ataxx
    include AlphaBeta

    attr_reader :nodes, :leaf

    def initialize
      super
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

      eval( position, player )
    end

    def cutoff( position, depth )
      position.final? || depth >= 4
    end

    def prune( position, player, moves )
      jumps = []
      splits = {}

      moves.each do |m|
        coords = m.to_coords

        dx = (coords.first.x - coords.last.x).abs
        dy = (coords.first.y - coords.last.y).abs

        if dx <= 1 && dy <= 1 && (dx == 1 || dy == 1)
          splits[coords.last] = m
        else
          jumps << m
        end
      end

      splits.values + jumps
    end
  end
end

