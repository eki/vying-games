require 'vying/rules'

module Minimax

  def analyze( position, player )
    h = {}
    position.ops.each{ |op| h[op] = search( position.apply( op ), player ) }
    h
  end

  def search( position, player, depth=0 )
    @nodes += 1 if respond_to? :nodes

    return evaluate( position, player ) if cutoff( position, depth )

    scores = position.ops.map do |op|
      search( position.apply( op ), player, depth+1 )
    end

    position.turn == player ? scores.max : scores.min
  end
end

