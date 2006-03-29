require 'benchmark'
require 'rules/connect6/connect6'
require 'rules/connectfour/connectfour'
require 'game'

n=10000

p6 = Connect6.init

Benchmark.bm(12) do |x|

  x.report( "init:" ) do
    n.times { Connect6.init }
  end

  x.report( "ops:" ) do
    n.times { Connect6.ops( p6 ) }
  end

  x.report( "final?:" ) do
    n.times { Connect6.final?( p6 ) }
  end

  x.report( "random moves:" ) do
    g = Game.new( Connect6 )
    n.times do
      if g.final?
        g = Game.new( Connect6 )
      end
      g << g.ops[rand(g.ops.length)]
    end
  end
end

