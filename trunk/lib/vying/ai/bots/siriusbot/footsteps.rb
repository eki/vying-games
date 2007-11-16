require 'vying/ai/bot'

class SiriusBot < Bot
  class Footsteps < Bot
    difficulty :easy

    def select( sequence, position, player )
      opp = player == :left ? :right : :left
      marker = position.board.occupied[:white].first

      if (player == :left  && marker.x == 5) ||     # about to lose
         (player == :right && marker.x == 1)
        bid = [position.points[player], position.points[opp]+1].min
        "#{player}_#{bid}"
      elsif (player == :left  && marker.x == 1) ||  # about to win
            (player == :right && marker.x == 5)
        "#{player}_#{position.points[player]}"
      elsif position.points[player] > 2 * position.points[opp]   # twice as many
        "#{player}_#{position.points[opp]+1}"                    # points
      else
        limit = [5, position.points[player]].min
        "#{player}_#{rand( limit ) + 1}"
      end
    end
  end
end

