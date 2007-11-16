require 'vying/ai/bot'
require 'vying/ai/search'

module AmazonsStrategies

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

end

