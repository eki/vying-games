# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying/ai/bot'

class VegaBot < Bot
  class Footsteps < Bot
    difficulty :medium

    def select( sequence, position, player )
      opp = player == :left ? :right : :left
      marker = position.board.occupied[:white].first

      if position.points[opp] == 0
        "#{player}_1"
      elsif (player == :left  && marker.x == 5) ||     # about to lose
            (player == :right && marker.x == 1)
        bid = [position.points[player], position.points[opp]+1].min
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
end

