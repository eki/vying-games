require 'vying/rules'
require 'vying/board/standard'

class ConnectFour < Rules

  info :name    => 'Connect Four',
       :aliases => ['Plot Four', 'Connect 4', "The Captain's Mistress"]

  attr_reader :board, :lastc, :lastp, :unused_ops

  def initialize_copy( original )
    super
    @unused_ops = original.unused_ops.map { |a| a.dup }
  end

  players [:red, :blue]

  @@init_ops = Coords.new( 7, 6 ).group_by { |c| c.x }.map do |sa|
    sa.map { |c| c.to_s }
  end

  def initialize( seed=nil )
    super

    @board = Board.new( 7, 6 )
    @lastc, @lastp = nil, :noone
    @unused_ops = @@init_ops.map { |a| a.dup }
  end

  def op?( op, player=nil )
    return false unless player.nil? || has_ops.include?( player )
    unused_ops.map { |a| a.last }.include?( op.to_s )
  end

  def ops( player=nil )
    return false unless player.nil? || has_ops.include?( player )
    (final? || (tmp = unused_ops.map { |a| a.last }) == []) ? nil : tmp
  end

  def apply!( op )
    c, p = Coord[op], turn
    board[c], @lastc, @lastp = p, c, p
    unused_ops.each { |a| a.delete( c.to_s ) }
    unused_ops.delete( [] )
    turn( :rotate )
    self
  end

  def final?
    return false if lastc.nil?
    return true  if unused_ops.empty?

    board.each_from( lastc, [:e,:w] ) { |p| p == lastp } >= 3 ||
    board.each_from( lastc, [:n,:s] ) { |p| p == lastp } >= 3 ||
    board.each_from( lastc, [:ne,:sw] ) { |p| p == lastp } >= 3 ||
    board.each_from( lastc, [:nw,:se] ) { |p| p == lastp } >= 3
  end

  def winner?( player )
    board.each_from( lastc, [:e,:w] ) { |p| p == player } >= 3 ||
    board.each_from( lastc, [:n,:s] ) { |p| p == player } >= 3 ||
    board.each_from( lastc, [:ne,:sw] ) { |p| p == player } >= 3 ||
    board.each_from( lastc, [:nw,:se] ) { |p| p == player } >= 3
  end

  def loser?( player )
    !draw? && player != lastp
  end

  def draw?
    board.count( nil ) == 0 &&
    board.each_from( lastc, [:e,:w] ) { |p| p == lastp } < 3 &&
    board.each_from( lastc, [:n,:s] ) { |p| p == lastp } < 3 &&
    board.each_from( lastc, [:ne,:sw] ) { |p| p == lastp } < 3 &&
    board.each_from( lastc, [:nw,:se] ) { |p| p == lastp } < 3
  end

  def hash
    [board, turn].hash
  end
end

