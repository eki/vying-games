require 'vying/ai/bot'
require 'vying/ai/bots/footsteps/footsteps'

class AI::Footsteps::MonteCarloBot < AI::Bot
  def select( sequence, position, player )
    n = 500
    ops = Hash.new( 0 )

    n.times do 
      p = position.dup

      p.players.each do |playa|
        if p.bids[playa] == :hidden  # if a players bid is hidden, we'll guess
          p.bids[playa] = rand( p.points[playa] ) + 1     
        end
      end

      first_op = p.ops( player )[rand( p.ops( player ).length )]

      p.apply!( first_op )

      until p.final?
        p.apply!( p.ops[rand( p.ops.length )] )
      end

      ops[first_op] += 4 if p.winner?( player )
      ops[first_op] -= 3 if p.loser?( player )
      ops[first_op] =  1 if p.draw?
    end

    #puts ops.inspect

    a = []
    ops.each do |op, score|
      a << [op] * score if score > 0
    end

    a.flatten!

    if a.length > 0
      a[rand( a.length )]
    else
      ops_invert = ops.invert
      ops_invert[ops_invert.keys.max]
    end
  end
end

