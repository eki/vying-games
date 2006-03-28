require 'benchmark'
require 'rules/connectfour/connectfour'
require 'game'

n=10000

Benchmark.bm(12) do |x|
  x.report( "ops:" ) do
    g = Game.new( ConnectFour )
    n.times do
      ops = g.ops
      if ops.nil?
        g = Game.new( ConnectFour )
        ops = g.ops
      end
      g << ops[rand(ops.length)]
    end
  end
end

