require 'vying/rules'

module AlphaBeta
  def analyze( position, player )
    h = {}

    ops = prune( position, position.ops ) if respond_to? :prune
    ops = order( position, position.ops ) if respond_to? :order
    ops ||= position.ops

    ops.each do |op|
      h[op] = search( position.apply( op ), player, -10**10, 10**10, 1 )
    end
    h
  end

  def search( position, player, a, b, depth=0 )
    @nodes += 1 if respond_to? :nodes

    return evaluate( position, player ) if cutoff( position, depth )

    ops = prune( position, position.ops ) if respond_to? :prune
    ops = order( position, position.ops ) if respond_to? :order
    ops ||= position.ops

    scores = ops.map_until do |op|
      v = search( position.apply( op ), player, a, b, depth+1 )

      # Check for alpha-beta cutoffs
      if position.turn == player
        a = [a,v].max
        return b if a >= b
      elsif position.turn != player
        b = [b,v].min
        return a if b <= a
      end

      v
    end

    position.turn == player ? scores.max : scores.min
  end
end

module Enumerable
  def map_until
    ml = []
    each do |o|
      mo = yield o
      return ml unless mo
      ml << mo
    end
    ml
  end
end

