require 'board/standard'
require 'game'

class ConnectFour < Rules

  info :name    => 'Connect Four',
       :aliases => ['Plot Four', 'Connect 4', "The Captain's Mistress"]

  position :board, :turn, :lastc, :lastp, :unused_ops
  display  :board

  class Position
    def dup
      d = super
      d.unused_ops = unused_ops.map { |a| a.dup }
      d
    end
  end

  players [:red, :blue]

  @@init_ops = Coords.new( 7, 6 ).group_by { |c| c.x }.map do |sa|
    sa.map { |c| c.to_s }
  end

  def ConnectFour.init( seed=nil )
    ps = players.dup
    uo = @@init_ops.map { |a| a.dup }
    Position.new( Board.new( 7, 6 ), ps, nil, :noone, uo )
  end

  def ConnectFour.op?( position, op, player=nil )
    return false unless player.nil? || has_ops( position ).include?( player )
    position.unused_ops.map { |a| a.last }.include?( op.to_s )
  end

  def ConnectFour.ops( position, player=nil )
    return false unless player.nil? || has_ops( position ).include?( player )
    tmp = position.unused_ops.map { |a| a.last }
    (final?( position ) || tmp == []) ? nil : tmp
  end

  def ConnectFour.apply( position, op )
    c, pos, p = Coord[op], position.dup, position.turn.now
    pos.board[c], pos.lastc, pos.lastp = p, c, p
    pos.unused_ops.each { |a| a.delete( c.to_s ) }
    pos.unused_ops.delete( [] )
    pos.turn.rotate!
    pos
  end

  def ConnectFour.final?( position )
    return false if position.lastc.nil?
    return true  if position.unused_ops.empty?

    b, lc, lp = position.board, position.lastc, position.lastp

    b.each_from( lc, [:e,:w] ) { |p| p == lp } >= 3 ||
    b.each_from( lc, [:n,:s] ) { |p| p == lp } >= 3 ||
    b.each_from( lc, [:ne,:sw] ) { |p| p == lp } >= 3 ||
    b.each_from( lc, [:nw,:se] ) { |p| p == lp } >= 3
  end

  def ConnectFour.winner?( position, player )
    b, lc, lp = position.board, position.lastc, position.lastp

    b.each_from( lc, [:e,:w] ) { |p| p == player } >= 3 ||
    b.each_from( lc, [:n,:s] ) { |p| p == player } >= 3 ||
    b.each_from( lc, [:ne,:sw] ) { |p| p == player } >= 3 ||
    b.each_from( lc, [:nw,:se] ) { |p| p == player } >= 3
  end

  def ConnectFour.loser?( position, player )
    !draw?( position ) && player != position.lastp
  end

  def ConnectFour.draw?( position )
    b, lc, lp = position.board, position.lastc, position.lastp

    b.count( nil ) == 0 &&
    b.each_from( lc, [:e,:w] ) { |p| p == lp } < 3 &&
    b.each_from( lc, [:n,:s] ) { |p| p == lp } < 3 &&
    b.each_from( lc, [:ne,:sw] ) { |p| p == lp } < 3 &&
    b.each_from( lc, [:nw,:se] ) { |p| p == lp } < 3
  end
end

