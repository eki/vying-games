require 'vying/ai/bot'

module AI::Connect6

  PATTERNS = { [:black, :black, :black] => 10,
               [:black, :black, nil   ] =>  2,
               [nil,    :black, :black] =>  2,
               [nil,    :black, nil   ] =>  0,
               [nil,    :black, :white] =>  0,
               [:white, :black, nil   ] =>  0,
               [:white, :black, :white] => -1,
               [:black, :black, :white] => -10,
               [:white, :black, :black] => -10,
               [:white, :white, :white] => 10,
               [:white, :white, nil   ] =>  2,
               [nil,    :white, :white] =>  2,
               [nil,    :white, nil   ] =>  0,
               [nil,    :white, :black] =>  0,
               [:black, :white, nil   ] =>  0,
               [:black, :white, :black] => -1,
               [:white, :white, :black] => -10,
               [:black, :white, :white] => -10 }

  def eval_neighbors( position, player )
    opp = player == :black ? :white : :black
    score = 0

    b = position.board

    b.occupied[player].each do |c|
      score += score_pattern( b, c, [:n,:s] )
      score += score_pattern( b, c, [:e,:w] )
      score += score_pattern( b, c, [:ne,:sw] )
      score += score_pattern( b, c, [:nw,:se] )
    end

    b.occupied[opp].each do |c|
      score -= score_pattern( b, c, [:n,:s] )
      score -= score_pattern( b, c, [:e,:w] )
      score -= score_pattern( b, c, [:ne,:sw] )
      score -= score_pattern( b, c, [:nw,:se] )
    end

    score
  end

  def eval_threats( position, player )
    score = 0

    position.board.threats.each do |t|
      if t.player == player
        score += 100 / (t.degree+1)  #shouldn't have to do this, degree == 0
      else                           #should mean that the position is final
        score -= 100 / (t.degree+1)  #in which case we shouldn't be evaluating
      end
    end

    puts "score nil!" if score.nil?
    score
  end

  def eval_player_threats( position, player )
    score = 0

    threats = position.board.threats

    p_fives = threats.select { |t| t.player == player && t.degree == 1 }
    p_fours = threats.select { |t| t.player == player && t.degree == 2 }
    p_threes = threats.select { |t| t.player == player && t.degree == 3 }
    p_twos = threats.select { |t| t.player == player && t.degree == 4 }

    score -=  60 if p_fives.length > 0
    score += 300 if p_fours.length >= 3
    score +=  30 if p_fours.length == 2 
    score +=   3 * p_threes.length
    score +=   1 * p_twos.length

    opp_fours = threats.select { |t| t.player != player && t.degree == 2 }
    opp_threes = threats.select { |t| t.player != player && t.degree == 3 }

    score -= 8000 if opp_fours.length >= 3
    score -=  800 if opp_fours.length == 2
    score -=  400 if opp_fours.length == 1

    score -= opp_threes.length

    score
  end

  def eval_random( position, player )
    rand( 100 ) - 50
  end

  def score_pattern( board, c, directions )
    ns = board.coords.neighbors_nil( c, directions )
    p = [ ns.first.nil? ? nil : board[ns.first],
          board[c],
          ns.last.nil? ? nil : board[ns.last] ]

    s = PATTERNS[p]
    if s.nil?
      puts "Couldn't find pattern #{[ns.first, c, ns.last]}"
    end
    s || 0
  end

  module Bot
    include AI::Connect6
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

