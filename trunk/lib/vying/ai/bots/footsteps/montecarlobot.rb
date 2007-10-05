require 'vying/ai/bot'
require 'vying/ai/bots/footsteps/footsteps'

class AI::Footsteps::MonteCarloBot < AI::Bot
  def select( sequence, position, player )
    n = 500
    moves = Hash.new( 0 )

    n.times do 
      p = position.dup

      p.players.each do |playa|
        if p.bids[playa] == :hidden  # if a players bid is hidden, we'll guess
          p.bids[playa] = rand( p.points[playa] ) + 1     
        end
      end

      first_move = p.moves( player )[rand( p.moves( player ).length )]

      p.apply!( first_move )

      until p.final?
        p.apply!( p.moves[rand( p.moves.length )] )
      end

      moves[first_move] += 4 if p.winner?( player )
      moves[first_move] -= 3 if p.loser?( player )
      moves[first_move] =  1 if p.draw?
    end

    #puts moves.inspect

    a = []
    moves.each do |move, score|
      a << [move] * score if score > 0
    end

    a.flatten!

    if a.length > 0
      a[rand( a.length )]
    else
      moves_invert = moves.invert
      moves_invert[moves_invert.keys.max]
    end
  end
end

