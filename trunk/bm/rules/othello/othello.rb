require 'benchmark'
require 'rules/othello/othello'
require 'game'

n=1000

pos = Othello.init

b = OthelloBoard.new( 8, 8 )
b[3,2] = Piece.black
b[3,3] = b[3,4] = b[3,5] = Piece.white
c = Coord[3,6]

p_a = Array.new( n ) { |i| b.dup }
a_a = Array.new( n ) { |i| pos.dup }

Benchmark.bm(14) do |x|

  x.report( "pos dup:" ) do
    n.times { pos.dup }
  end

  x.report( "valid?:" ) do
    n.times { b.valid?( c, Piece.black ) }
  end

  x.report( "place:" ) do
    p_a.each { |board| board.place( c, Piece.black ) }
  end

  x.report( "frontier:" ) do
    b = pos.board
    n.times do
      p = pos.dup
      p.occupied << c
      p.frontier += b.coords.neighbors( c ).select { |c| b[c].nil? }
      p.frontier.uniq!
      p.frontier.delete( c )
    end
  end

  x.report( "init:" ) do
    n.times { Othello.init }
  end

  x.report( "op?:" ) do
    n.times { Othello.op?( pos, :d3 ) }
  end

  x.report( "apply:" ) do
    a_a.each { |position| Othello.apply( position, :d3 ) }
  end

  x.report( "ops:" ) do
    n.times { Othello.ops( pos ) }
  end

  x.report( "ops (nc):" ) do
    n.times { pos.ops_cache = :ns; Othello.ops( pos ) }
  end

  x.report( "turn.next!:" ) do
    p = pos.dup
    n.times { p.turn.next! }
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

