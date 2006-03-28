require 'benchmark'
require 'rules/connect6/connect6'
require 'game'

n=1000

Benchmark.bm(12) do |x|
  x.report( "ops:" ) do
    g = Game.new( Connect6 )
    n.times do
      ops = g.ops
      if ops.nil?
        g = Game.new( Connect6 )
        ops = g.ops
      end
      g << ops[rand(ops.length)]
    end
  end
end

