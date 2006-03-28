require 'benchmark'
require 'board/standard'

n=10000

b = Board.new( 8, 8 )

coord = Coord[4,4]
coord2 = Coord[3,3]
row = b.coords.row( Coord[4,4] )
col = b.coords.column( Coord[4,4] )
diagpos = b.coords.diagonal( Coord[4,4], 1 )
diagneg = b.coords.diagonal( Coord[3,3], -1 )

Benchmark.bm(12) do |x|
  x.report( "new:" ) do
    n.times { Board.new }
  end

  x.report( "dup:" ) do
    n.times { b.dup }
  end

  x.report( "[x,y]:" ) do
    n.times { b[4,4] }
  end

  x.report( "[x,y]=:" ) do
    n.times { b[4,4] = :blah }
  end

  x.report( "[c new]:" ) do
    n.times { b[Coord.new(4,4)] }
  end

  x.report( "[c]:" ) do
    n.times { b[coord] }
  end

  x.report( "[c new]=:" ) do
    n.times { b[Coord.new(4,4)] = :foo }
  end

  x.report( "[c]=:" ) do
    n.times { b[coord] = :foo }
  end

  x.report( "row" ) do
    n.times { b.coords.row( coord ) }
  end

  x.report( "column" ) do
    n.times { b.coords.column( coord ) }
  end

  x.report( "diag +1" ) do
    n.times { b.coords.diagonal( coord, 1 ) }
  end

  x.report( "diag -1" ) do
    n.times { b.coords.diagonal( coord2, -1 ) }
  end

  x.report( "neighbors" ) do
    n.times { b.coords.neighbors( coord ) }
  end

  x.report( "next (nw)" ) do
    n.times { b.coords.next( coord, :nw ) }
  end

  x.report( "line (n)" ) do
    n.times { b.coords.next( coord, :n ) }
  end

  x.report( "line (nw)" ) do
    n.times { b.coords.next( coord, :nw ) }
  end

  x.report( "[row]:" ) do
    n.times { b[row] }
  end

  x.report( "[column]:" ) do
    n.times { b[col] }
  end

  x.report( "[diagpos]:" ) do
    n.times { b[diagpos] }
  end

  x.report( "[diagneg]:" ) do
    n.times { b[diagneg] }
  end

  x.report( "[b.coords.row]" ) do
    n.times { b[b.coords.row( coord )] }
  end

  x.report( "b.to_s(row)" ) do
    n.times { b.to_s( row ) }
  end

  x.report( "Board.to_s" ) do
    n.times { Board.to_s( b[row] ) }
  end
end

