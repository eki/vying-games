require 'vying/ai/bot'
require 'vying/ai/bots/footsteps/footsteps'

class AI::Footsteps::MediumBot < AI::Bot
  def select( sequence, position, player )
    opp = player == :left ? :right : :left
    marker = position.board.occupied[:white].first

    if (player == :left  && marker.x == 5) ||     # about to lose
       (player == :right && marker.x == 1)
      bid = [position.points[player], position.points[opp]].min
      "#{player}_#{rand( bid ) + 1}"
    elsif (player == :left  && marker.x == 1) ||  # about to win
          (player == :right && marker.x == 5) &&
          position.points[player] > position.points[opp]
      "#{player}_#{position.points[player]}"
    elsif position.points[player] > 2 * position.points[opp]   # twice as many
      "#{player}_#{position.points[opp]+1}"                    # points
    else
      limit = [15, position.points[player]].min
      "#{player}_#{rand( limit ) + 1}"
    end
  end
end

