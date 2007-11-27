# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

module OwareStrategies

  def eval_score( position, player )
    opp = player == :one ? :two : :one

    position.score( player ) - position.score( opp )
  end

end

