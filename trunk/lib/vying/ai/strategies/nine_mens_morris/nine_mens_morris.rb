require 'vying/ai/bot'

module AI::NineMensMorris

  def eval_score( position, player )
    opp = player == :black ? :white : :black

    4 * position.score( player ) - position.score( opp )
  end

  def eval_mills( position, player )
    opp = player == :black ? :white : :black

    score = 0

    position.board.occupied[player].each do |c|
      score += 2 if position.mill?( c )
    end

    position.board.occupied[opp].each do |c|
      score -= 2 if position.mill?( c )
    end

    score
  end

  def eval_mobility( position, player )
    moves = position.moves
    moves ? moves.length : 0
  end

end

