
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

