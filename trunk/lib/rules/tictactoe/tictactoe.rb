require 'board/standard'
require 'game'

class TicTacToe < Rules

  info :name      => 'Tic Tac Toe',
       :aliases   => ['Noughts and Crosses', 'Naughts and Crosses',
                      "X's and O's", 'Tick Tat Toe', 'Tit Tat Toe'],
       :resources => ['Wikipedia <http://en.wikipedia.org/wiki/Tic-tac-toe>']

  position :board, :turn, :lastc, :lastp, :unused_ops

  players [Piece.x, Piece.o]

  @@init_ops = Coords.new( 3, 3 ).map { |c| c.to_s }

  def TicTacToe.init( seed=nil )
    ps = PlayerSet.new( *players )
    Position.new( Board.new( 3, 3 ), ps, nil, :noone, @@init_ops.dup )
  end

  def TicTacToe.op?( position, op )
    position.unused_ops.include?( op.to_s )
  end

  def TicTacToe.ops( position )
    final?( position ) || position.unused_ops == [] ? nil : position.unused_ops
  end

  def TicTacToe.apply( position, op )
    c, pos, p = Coord[op], position.dup, position.turn.current
    pos.board[c], pos.lastc, pos.lastp = p, c, p
    pos.unused_ops.delete( c.to_s )
    pos.turn.next!
    pos
  end

  def TicTacToe.final?( position )
    return false if position.lastc.nil?
    return true  if position.unused_ops.empty?

    b, lc, lp = position.board, position.lastc, position.lastp

    b.each_from( lc, [:e,:w] ) { |p| p == lp } == 2 ||
    b.each_from( lc, [:n,:s] ) { |p| p == lp } == 2 ||
    b.each_from( lc, [:ne,:sw] ) { |p| p == lp } == 2 ||
    b.each_from( lc, [:nw,:se] ) { |p| p == lp } == 2
  end

  def TicTacToe.winner?( position, player )
    TicTacToe.final?( position ) && !TicTacToe.draw?( position ) &&
    position.lastp == player
  end

  def TicTacToe.loser?( position, player )
    TicTacToe.final?( position ) && !TicTacToe.draw?( position ) &&
    position.lastp != player
  end

  def TicTacToe.draw?( position )
    b, lc, lp = position.board, position.lastc, position.lastp

    position.unused_ops.empty? &&
    b.each_from( lc, [:e,:w] ) { |p| p == lp } != 2 &&
    b.each_from( lc, [:n,:s] ) { |p| p == lp } != 2 &&
    b.each_from( lc, [:ne,:sw] ) { |p| p == lp } != 2 &&
    b.each_from( lc, [:nw,:se] ) { |p| p == lp } != 2
  end
end

