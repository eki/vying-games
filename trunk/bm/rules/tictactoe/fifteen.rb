require 'benchmark'
require 'rules/tictactoe/fifteen'
require 'game'

n=10000

pos = Fifteen.init

Benchmark.bm(14) do |x|

  x.report( "init:" ) do
    n.times { Fifteen.init }
  end

  x.report( "ops:" ) do
    n.times { Fifteen.ops( pos ) }
  end

  x.report( "final?:" ) do
    n.times { Fifteen.final?( pos ) }
  end

  x.report( "random moves:" ) do
    g = Game.new( Fifteen )
    n.times do
      if g.final?
        g = Game.new( Fifteen )
      end
      g << g.ops[rand(g.ops.length)]
    end
  end
end

