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

  FOURS = [[Coord[:a1], Coord[:b1], Coord[:a2], Coord[:b2]],
           [Coord[:b1], Coord[:c1], Coord[:b2], Coord[:c2]],
           [Coord[:c1], Coord[:d1], Coord[:c2], Coord[:d2]],
           [Coord[:d1], Coord[:e1], Coord[:d2], Coord[:e2]],
           [Coord[:e1], Coord[:f1], Coord[:e2], Coord[:f2]],
           [Coord[:f1], Coord[:g1], Coord[:f2], Coord[:g2]],

           [Coord[:a2], Coord[:b2], Coord[:a3], Coord[:b3]],
           [Coord[:b2], Coord[:c2], Coord[:b3], Coord[:c3]],
           [Coord[:c2], Coord[:d2], Coord[:c3], Coord[:d3]],
           [Coord[:d2], Coord[:e2], Coord[:d3], Coord[:e3]],
           [Coord[:e2], Coord[:f2], Coord[:e3], Coord[:f3]],
           [Coord[:f2], Coord[:g2], Coord[:f3], Coord[:g3]],

           [Coord[:a3], Coord[:b3], Coord[:a4], Coord[:b4]],
           [Coord[:b3], Coord[:c3], Coord[:b4], Coord[:c4]],
           [Coord[:c3], Coord[:d3], Coord[:c4], Coord[:d4]],
           [Coord[:d3], Coord[:e3], Coord[:d4], Coord[:e4]],
           [Coord[:e3], Coord[:f3], Coord[:e4], Coord[:f4]],
           [Coord[:f3], Coord[:g3], Coord[:f4], Coord[:g4]],

           [Coord[:a4], Coord[:b4], Coord[:a5], Coord[:b5]],
           [Coord[:b4], Coord[:c4], Coord[:b5], Coord[:c5]],
           [Coord[:c4], Coord[:d4], Coord[:c5], Coord[:d5]],
           [Coord[:d4], Coord[:e4], Coord[:d5], Coord[:e5]],
           [Coord[:e4], Coord[:f4], Coord[:e5], Coord[:f5]],
           [Coord[:f4], Coord[:g4], Coord[:f5], Coord[:g5]],

           [Coord[:a5], Coord[:b5], Coord[:a6], Coord[:b6]],
           [Coord[:b5], Coord[:c5], Coord[:b6], Coord[:c6]],
           [Coord[:c5], Coord[:d5], Coord[:c6], Coord[:d6]],
           [Coord[:d5], Coord[:e5], Coord[:d6], Coord[:e6]],
           [Coord[:e5], Coord[:f5], Coord[:e6], Coord[:f6]],
           [Coord[:f5], Coord[:g5], Coord[:f6], Coord[:g6]],

           [Coord[:a6], Coord[:b6], Coord[:a7], Coord[:b7]],
           [Coord[:b6], Coord[:c6], Coord[:b7], Coord[:c7]],
           [Coord[:c6], Coord[:d6], Coord[:c7], Coord[:d7]],
           [Coord[:d6], Coord[:e6], Coord[:d7], Coord[:e7]],
           [Coord[:e6], Coord[:f6], Coord[:e7], Coord[:f7]],
           [Coord[:f6], Coord[:g6], Coord[:f7], Coord[:g7]]]

  def eval_stability( position, player )
    score = 0
    FOURS.each do |f|
      pieces = position.board[*f]
      score += 4 if pieces.all? { |p| p == player || p == :x }
    end
    score
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

      t = position.turn
      p = position.apply( position.moves.first )
      return position.moves.first if p.turn == t

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

