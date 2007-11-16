require 'vying/ai/bot'

module AtaxxStrategies

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

end

