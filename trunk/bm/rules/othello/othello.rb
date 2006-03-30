require 'benchmark'
require 'rules/othello/othello'
require 'game'

n=100

pos = Othello.init

Benchmark.bm(14) do |x|

  x.report( "init:" ) do
    n.times { Othello.init }
  end

  x.report( "ops:" ) do
    n.times { Othello.ops( pos ) }
  end

  x.report( "final?:" ) do
    n.times { Othello.final?( pos ) }
  end

  x.report( "random moves:" ) do
    g = Game.new( Othello )
    n.times do
      if g.final?
        g = Game.new( Othello )
      end
      g << g.ops[rand(g.ops.length)]
    end
  end
end

