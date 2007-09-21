require 'vying/ai/bot'
require 'vying/ai/bots/footsteps/footsteps'

require 'sqlite'

class AI::Footsteps::OptimalBot < AI::Bot

  $:.each do |d|
    Dir.glob( "#{d}/**/ai/bots/footsteps/*" ) do |f|
      if f =~ /footsteps\.db$/
        FOOTSTEPS_DB = f unless defined? FOOTSTEPS_DB
      end
    end
  end

  def select( sequence, position, player )
    opp = player == :left ? :right : :left
    marker = position.board.occupied[:white].first

    dist = player == :left ? marker.x : 6 - marker.x
    r = rand

    db = SQLite::Database.new( FOOTSTEPS_DB )

    b = db.get_first_value( "select bid from footsteps " +
                            "  where points_a = ? " +
                            "    and points_b = ? " +
                            "    and distance_a = ? " +
                            "    and prob_min <= ? " +
                            "    and prob_max > ? ", 
                            position.points[player],
                            position.points[opp],
                            dist,
                            r, r )

    "#{player}_#{b.nil? ? 1 : b}"
  end
end

