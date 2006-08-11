require 'board/standard'
require 'game'

class Connect6 < Rules

  info :name      => 'Connect6',
       :resources => ['Wikipedia <http://en.wikipedia.org/wiki/Connect6>']

  attr_reader :board, :turn, :lastc, :lastp, :unused_ops

  random false

  players [:black, :white]

  @@init_ops = Coords.new( 19, 19 ).map { |c| c.to_s }

  def initialize( seed=nil )
    super

    @board = Board.new( 19, 19 )
    @turn = [:black, :white, :white, :black]
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
    c, p = Coord[op], turn.now
    board[c], @lastc, @lastp = p, c, p
    @unused_ops.delete( c.to_s )
    turn.rotate!
    self
  end

  def final?
    return false if lastc.nil?
    return true  if unused_ops.empty?

    board.each_from( lastc, [:e,:w] ) { |p| p == lastp } >= 5 ||
    board.each_from( lastc, [:n,:s] ) { |p| p == lastp } >= 5 ||
    board.each_from( lastc, [:ne,:sw] ) { |p| p == lastp } >= 5 ||
    board.each_from( lastc, [:nw,:se] ) { |p| p == lastp } >= 5
  end

  def winner?( player )
    lastp == player &&
    (board.each_from( lastc, [:e,:w] ) { |p| p == player } >= 5 ||
     board.each_from( lastc, [:n,:s] ) { |p| p == player } >= 5 ||
     board.each_from( lastc, [:ne,:sw] ) { |p| p == player } >= 5 ||
     board.each_from( lastc, [:nw,:se] ) { |p| p == player } >= 5)
  end

  def loser?( player )
    !draw? && player != lastp
  end

  def draw?
    unused_ops.empty? &&
    board.each_from( lastc, [:e,:w] ) { |p| p == lastp } < 5 &&
    board.each_from( lastc, [:n,:s] ) { |p| p == lastp } < 5 &&
    board.each_from( lastc, [:ne,:sw] ) { |p| p == lastp } < 5 &&
    board.each_from( lastc, [:nw,:se] ) { |p| p == lastp } < 5
  end
end

