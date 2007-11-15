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

  def eval_score( position, player )
    opp = player == :black ? :white : :black
    position.score( player ) - position.score( opp )
  end

  def eval_territories( position, player )
    opp = player == :black ? :white : :black
    score = 0
    largest = 0
    largest_t = nil

    position.board.territories.each do |t|
      score += 10 if t.send( player ).empty? && t.coords.length < 5
      score -= 10 if t.send( opp ).empty?    && t.coords.length < 5
      if largest < t.coords.length
        largest = t.coords.length
        largest_t = t
      end
    end

    score += 30 unless largest_t.send( player ).empty?

    score
  end

  def eval_mobility( position, player )
    position.moves.length
  end

  def eval_centrality( position, player )
    opp = player == :black ? :white : :black
    score = 0
    
    position.board.occupied[player].each do |c|
      score += 10 / ((5 - c.x).abs + 1)
      score += 10 / ((5 - c.y).abs + 1)
    end

    position.board.occupied[opp].each do |c|
      score -= 10 / ((5 - c.x).abs + 1)
      score -= 10 / ((5 - c.y).abs + 1)
    end

    score
  end

  module Bot
    include AI::Amazons
    include AlphaBeta

    def initialize
      super
    end

    def select( sequence, position, player )
      return position.moves.first if position.moves.length == 1

      score, move = fuzzy_best( analyze( position, player ), 0 )
      puts "**** Score: #{score}"
      move
    end

    def forfeit?( sequence, position, player )
      opp = player == :black ? :white : :black
      territories = position.board.territories

      territories.all? { |t| t.black.empty? || t.white.empty? } &&
      position.score( opp ) > position.score( player )
    end

    def evaluate( position, player )
      return position.score( player ) * 1000 if position.final?
      eval( position, player )
    end

    def cutoff( position, depth )
      position.final? || depth >= 1
    end

    def prune( position, player, moves )
      opp = player == :black ? :white : :black
      pq = []

      position.board.territories.each do |t|
        qs = t.send( player )
        pq += qs if !qs.empty? && t.send( opp ).empty?
      end

      return moves if pq.empty?

      keep = moves.select do |m|
        cs = m.to_coords
        ! pq.include?( cs.first )
      end

      keep.empty? ? moves : keep
    end
  end
end

