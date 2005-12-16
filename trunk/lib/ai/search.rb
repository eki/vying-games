
require 'game'

class Minimax

  attr_reader :rules
  attr_accessor :cutoff, :evaluate

  def initialize( rules )
    @rules = rules
    @cutoff = lambda { |s,d| rules.final?( s ) }
    @evaluate = lambda { |s,m,d| rules.score( s, m ) }
  end

  def search( state, max=nil, depth=0 )
    max ||= state.turn.current
    return evaluate.call( state, max, depth ) if cutoff.call( state, depth )
    ops = rules.ops( state )
    scores = ops.map { |op| [search( op.call, max, depth+1 )[0],op] }
    return state.turn.current == max ? scores.max : scores.min
  end
end

class Negamax
  INFINITY = 1.0/0.0

  attr_reader :rules
  attr_accessor :cutoff, :evaluate

  def initialize( rules )
    @rules = rules
    @cutoff = lambda { |s,d| rules.final?( s ) }
    @evaluate = lambda { |s,m,d| rules.score( s, m ) }
  end

  def search( state, max=nil, depth=0 )
    max ||= state.turn.current
    return evaluate.call( state, max, depth ) if cutoff.call( state, depth )
    ops = rules.ops( state )
    best = [-INFINITY, nil]
    ops.each do |op|
      score, op_old = search( op.call, max, depth+1 )
      best = [best,[(depth == 0 ? score: -score),op]].max
    end
    best
  end
end

class AlphaBetaNegamax
  INFINITY = 1.0/0.0

  attr_reader :rules
  attr_accessor :cutoff, :evaluate

  def initialize( rules )
    @rules = rules
    @cutoff = lambda { |s,d| rules.final?( s ) }
    @evaluate = lambda { |s,m,d| rules.score( s, s.turn.previous ) }
  end

  def search0( state, max=nil, depth=0, alpha=-INFINITY, beta=INFINITY )
    return evaluate.call( state, max, depth ) if cutoff.call( state, depth )
    rules.ops( state ).each do |op|
      score = -search0( op.call, max, depth+1, -beta, -alpha )
      if score >= beta
        return beta
      else score > alpha
        alpha = score
      end
    end
    alpha
  end

  def search( state )
    max = state.turn.current
    depth = 0
    ops = rules.ops( state )
    scores = ops.map do |op| 
      [search0( op.call, max, depth+1, -INFINITY, INFINITY ),op]
    end
    scores.max
  end
end

