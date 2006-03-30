require 'benchmark'
require 'rules/tictactoe/tictactoe'
require 'game'

n=10000

pos = TicTacToe.init

Benchmark.bm(14) do |x|

  x.report( "init:" ) do
    n.times { TicTacToe.init }
  end

  x.report( "ops:" ) do
    n.times { TicTacToe.ops( pos ) }
  end

  x.report( "final?:" ) do
    n.times { TicTacToe.final?( pos ) }
  end

  x.report( "random moves:" ) do
    g = Game.new( TicTacToe )
    n.times do
      if g.final?
        g = Game.new( TicTacToe )
      end
      g << g.ops[rand(g.ops.length)]
    end
  end
end

