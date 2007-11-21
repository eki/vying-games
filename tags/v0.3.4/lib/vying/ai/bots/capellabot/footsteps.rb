require 'vying/ai/bot'

class CapellaBot < Bot
  class Footsteps < Bot
    difficulty :medium

    def select( sequence, position, player )
      opp = player == :left ? :right : :left
      marker = position.board.occupied[:white].first

      necessity = player == :left ? [-8, -2,  2, 2,  4,  6, 10][marker.x] :
                                    [10,  6,  4, 2,  2, -2, -8][marker.x]

      p_dist = player == :left ? marker.x : 6 - marker.x
      opp_dist =  opp == :left ? marker.x : 6 - marker.x

      if position.bid_history[opp].length > 0
        opp_avg = position.bid_history[opp].inject( 0 ) { |s,b| s + b } /
                  position.bid_history[opp].length
      else
        opp_avg = rand( 15 )
      end

      if (player == :left  && marker.x == 1) ||  # about to win
            (player == :right && marker.x == 5) &&
            position.points[player] > position.points[opp]
        "#{player}_#{position.points[player]}"
      else
        upper_limit = [opp_avg + necessity * 2, 
                       [1, position.points[player] - p_dist].max,
                       [1, position.points[opp] - opp_dist].max].min
        lower_limit = [opp_avg, 1].max
  
        if upper_limit < lower_limit
          upper_limit, lower_limit = lower_limit, upper_limit 
          upper_limit = [upper_limit,
                         [1, position.points[player] - p_dist].max,
                         [1, position.points[opp] - opp_dist].max].min
          lower_limit = [lower_limit, 1].max
        end

        bid = upper_limit == lower_limit ? upper_limit :
                rand( upper_limit - lower_limit ) + lower_limit

        "#{player}_#{bid}"
      end
    end
  end
end

