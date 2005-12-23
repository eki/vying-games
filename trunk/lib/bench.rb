require 'benchmark'
require 'board'

n=1000

b = Board.new

Benchmark.bm(7) do |x|
  x.report( "new:" ) do
    n.times { Board.new }
  end

  x.report( "dup:" ) do
    n.times { b.dup }
  end

  x.report( "rotate" ) do
    n.times { b.rotate( 45 ) }
  end

  x.report( "assign" ) do
    n.times { b[0,0] = b[1,1] }
  end

end

