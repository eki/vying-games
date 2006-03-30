require 'benchmark'
require 'rules/connectfour/connectfour'
require 'game'

n=10000

pos = ConnectFour.init

Benchmark.bm(14) do |x|

  x.report( "init:" ) do
    n.times { ConnectFour.init }
  end

  x.report( "ops:" ) do
    n.times { ConnectFour.ops( pos ) }
  end

  x.report( "final?:" ) do
    n.times { ConnectFour.final?( pos ) }
  end

  x.report( "random moves:" ) do
    g = Game.new( ConnectFour )
    n.times do
      if g.final?
        g = Game.new( ConnectFour )
      end
      g << g.ops[rand(g.ops.length)]
    end
  end
end

