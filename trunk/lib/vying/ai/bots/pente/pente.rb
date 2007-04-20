require 'vying/ai/bot'

module AI::Pente

  def eval_threats( position, player )
    score = 0

    threats = position.board.threats

    p_fours = threats.select { |t| t.player == player && t.degree == 1 }
    p_threes = threats.select { |t| t.player == player && t.degree == 2 }
    p_twos = threats.select { |t| t.player == player && t.degree == 3 }

    score += 300 if p_fours.length >= 2
    score +=  30 if p_fours.length == 1 
    score +=   3 * p_threes.length
    score +=   1 * p_twos.length

    opp_fours = threats.select { |t| t.player != player && t.degree == 1 }
    opp_threes = threats.select { |t| t.player != player && t.degree == 2 }

    score -= 8000 if opp_fours.length >= 2
    score -=  800 if opp_fours.length == 1

    score -= opp_threes.length

    score
  end

  def eval_score( position, player )
    opp = player == :black ? :white : :black

    2 ** (position.score( player ) / 2) - 2 ** (position.score( opp ) / 2)
  end

  def eval_random( position, player )
    rand( 100 ) - 50
  end

  module Bot
    include AI::Pente
    include AlphaBeta

    attr_reader :nodes, :leaf

    def initialize
      super
    end

    def select( sequence, position, player )
      return position.ops.first if position.ops.length == 1

      @leaf, @nodes = 0, 0
      score, op = best( analyze( position, player ) )
      puts "**** Searched #{nodes}:#{leaf} positions, best: #{score}"

      op
    end

    def evaluate( position, player )
      @leaf += 1

      return  1000 if position.final? && position.winner?( player )
      return -1000 if position.final? && position.loser?( player )
      return     0 if position.final?

      eval( position, player )
    end

    def cutoff( position, depth )
      position.final? || depth >= 2
    end

    def prune( position, player, ops )
      b = position.board

      occupied = b.occupied[:black] || []
      occupied += b.occupied[:white] if b.occupied[:white]

      return ops[rand(ops.length)] if occupied.length == 0

      keep = []

      occupied.each do |c| 
        b.coords.neighbors( c ).each do |nc|
          keep << nc if b[nc].nil?
        end
      end

      keep.uniq!

      keep -= occupied
      keep.map! { |c| c.to_s }

      keep
    end
  end
end

