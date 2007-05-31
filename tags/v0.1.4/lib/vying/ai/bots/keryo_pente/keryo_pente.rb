require 'vying/ai/bot'

module AI::KeryoPente

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

  def eval_threats2( position, player )
    score = 0

    threats = position.board.threats.dup

     p_fours, p_threes, p_twos, o_fours, o_threes, o_twos = 0, 0, 0, 0, 0, 0

    while t = threats.pop
      if t.degree == 1
        overlap = threats.select { |t2| t.occupied == t2.occupied }

        if t.player == player
          p_fours += (overlap.length == 1) ? 2 : 1
        else
          o_fours += (overlap.length == 1) ? 2 : 1
        end

        threats -= overlap

      elsif t.degree == 2
        overlap = threats.select { |t2| t.occupied == t2.occupied }

        if t.player == player
          p_threes += (overlap.length == 2) ? 2 : 1
        else
          o_threes += (overlap.length == 2) ? 2 : 1
        end

        threats -= overlap

      elsif t.degree == 3
        overlap = threats.select { |t2| t.occupied == t2.occupied }

        if t.player == player
          p_twos += (overlap.length == 3) ? 2 : 1
        else
          o_twos += (overlap.length == 3) ? 2 : 1
        end

        threats -= overlap
      end
    end

    score += 100 * p_fours   if p_fours >= 2
    score +=  50             if p_fours == 1
    score +=  51 * p_threes  if p_threes >= 2
    score +=  10             if p_threes == 1
    score +=   1             if p_twos > 0

    score -= 200 * o_fours
    score -= 200 * o_threes
    score +=  20 * o_twos

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
    include AI::KeryoPente
    include AlphaBeta

    attr_reader :nodes, :leaf

    def initialize
      super
    end

    def select( sequence, position, player )
      return position.ops.first if position.ops.length == 1

      @leaf, @nodes = 0, 0
      score, op = fuzzy_best( analyze( position, player ), 1 )
      puts "**** Searched #{nodes}:#{leaf} positions, best: #{score}"

      op
    end

    def evaluate( position, player )
      @leaf += 1

      return  10000 if position.final? && position.winner?( player )
      return -10000 if position.final? && position.loser?( player )
      return      0 if position.final?

      eval( position, player )
    end

    def cutoff( position, depth )
      position.final? || depth >= 2
    end

    def prune( position, player, ops )
      b = position.board

      occupied = b.occupied[:black] || []
      occupied += b.occupied[:white] if b.occupied[:white]

      return ["j9"] if occupied.length == 0

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

