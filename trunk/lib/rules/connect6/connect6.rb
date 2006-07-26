require 'board/standard'
require 'game'

class Connect6 < Rules

  info :name      => 'Connect6',
       :resources => ['Wikipedia <http://en.wikipedia.org/wiki/Connect6>']

  position :board, :turn, :lastc, :lastp, :unused_ops
  players [:black, :white]

  @@init_ops = Coords.new( 19, 19 ).map { |c| c.to_s }

  def Connect6.init( seed=nil )
    ps = [:black, :white, :white, :black]
    Position.new( Board.new( 19, 19 ), ps, nil, :noone, @@init_ops.dup )
  end

  def Connect6.op?( position, op )
    position.unused_ops.include?( op.to_s )
  end

  def Connect6.ops( position )
    final?( position ) || position.unused_ops == [] ? nil : position.unused_ops
  end

  def Connect6.apply( position, op )
    c, pos, p = Coord[op], position.dup, position.turn.now
    pos.board[c], pos.lastc, pos.lastp = p, c, p
    pos.unused_ops.delete( c.to_s )
    pos.turn.rotate!
    pos
  end

  def Connect6.final?( position )
    return false if position.lastc.nil?
    return true  if position.unused_ops.empty?

    b, lc, lp = position.board, position.lastc, position.lastp

    b.each_from( lc, [:e,:w] ) { |p| p == lp } >= 5 ||
    b.each_from( lc, [:n,:s] ) { |p| p == lp } >= 5 ||
    b.each_from( lc, [:ne,:sw] ) { |p| p == lp } >= 5 ||
    b.each_from( lc, [:nw,:se] ) { |p| p == lp } >= 5
  end

  def Connect6.winner?( position, player )
    b, lc, lp = position.board, position.lastc, position.lastp

    lp == player &&
    (b.each_from( lc, [:e,:w] ) { |p| p == player } >= 5 ||
     b.each_from( lc, [:n,:s] ) { |p| p == player } >= 5 ||
     b.each_from( lc, [:ne,:sw] ) { |p| p == player } >= 5 ||
     b.each_from( lc, [:nw,:se] ) { |p| p == player } >= 5)
  end

  def Connect6.loser?( position, player )
    !draw?( position ) && player != position.lastp
  end

  def Connect6.draw?( position )
    b, lc, lp = position.board, position.lastc, position.lastp

    position.unused_ops.empty? &&
    b.each_from( lc, [:e,:w] ) { |p| p == lp } < 5 &&
    b.each_from( lc, [:n,:s] ) { |p| p == lp } < 5 &&
    b.each_from( lc, [:ne,:sw] ) { |p| p == lp } < 5 &&
    b.each_from( lc, [:nw,:se] ) { |p| p == lp } < 5
  end
end

