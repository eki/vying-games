require 'vying/ai/bot'

module AI::Amazons

  def eval_neighbors( position, player )
    opp = player == :black ? :white : :black
    score = 0

    b = position.board

    b.occupied[player].each do |c|
      b.coords.neighbors_nil( c ).each do |nc|
        score -= 1 if nc.nil? || !b[nc].nil? 
      end
    end

    position.board.occupied[opp].each do |c|
      b.coords.neighbors_nil( c ).each do |nc|
        score += 1 if nc.nil? || !b[nc].nil? 
      end
    end

    score
  end

  module Bot
    include AI::Amazons

    def initialize
      super
    end

    def select( sequence, position, player )
      return position.ops.first if position.ops.length == 1

      score, op = best( analyze( position, player ) )
      puts "**** Score: #{score}"
      op
    end

    def evaluate( position, player )
      return position.score( player ) * 1000 if position.final?
      eval( position, player )
    end
  end
end

