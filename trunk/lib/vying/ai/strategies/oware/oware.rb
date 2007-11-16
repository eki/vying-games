require 'vying/ai/bot'

module AI::Oware

  def eval_score( position, player )
    opp = player == :one ? :two : :one

    position.score( player ) - position.score( opp )
  end

end

