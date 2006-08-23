require 'vying/rules'
require 'vying/board/standard'

class TicTacToe < Rules

  info :name      => 'Tic Tac Toe',
       :aliases   => ['Noughts and Crosses', 'Naughts and Crosses',
                      "X's and O's", 'Tick Tat Toe', 'Tit Tat Toe'],
       :resources => ['Wikipedia <http://en.wikipedia.org/wiki/Tic-tac-toe>']

  attr_reader :board, :lastc, :lastp, :unused_ops

  players [:x, :o]

  @@init_ops = Coords.new( 3, 3 ).map { |c| c.to_s }

  def initialize( seed=nil )
    super

    @board = Board.new( 3, 3 )
    @lastc, @lastp = nil, :noone
    @unused_ops = @@init_ops.dup
  end

  def op?( op, player=nil )
    return false unless player.nil? || has_ops.include?( player )
    unused_ops.include?( op.to_s )
  end

  def ops( player=nil )
    return false unless player.nil? || has_ops.include?( player )
    final? || unused_ops == [] ? nil : unused_ops
  end

  def apply!( op )
    c, p = Coord[op], turn
    board[c], @lastc, @lastp = p, c, p
    unused_ops.delete( c.to_s )
    turn( :rotate )
    self
  end

  def final?
    return false if lastc.nil?
    return true  if unused_ops.empty?

    board.each_from( lastc, [:e,:w] ) { |p| p == lastp } == 2 ||
    board.each_from( lastc, [:n,:s] ) { |p| p == lastp } == 2 ||
    board.each_from( lastc, [:ne,:sw] ) { |p| p == lastp } == 2 ||
    board.each_from( lastc, [:nw,:se] ) { |p| p == lastp } == 2
  end

  def winner?( player )
    final? && !draw? && lastp == player
  end

  def loser?( player )
    final? && !draw? && lastp != player
  end

  def draw?
    unused_ops.empty? &&
    board.each_from( lastc, [:e,:w] ) { |p| p == lastp } != 2 &&
    board.each_from( lastc, [:n,:s] ) { |p| p == lastp } != 2 &&
    board.each_from( lastc, [:ne,:sw] ) { |p| p == lastp } != 2 &&
    board.each_from( lastc, [:nw,:se] ) { |p| p == lastp } != 2
  end

  def hash
    [board, turn].hash
  end
end

