require 'vying/rules'
require 'vying/board/board'

class Connect4 < Rules

  info :name    => 'Connect Four',
       :aliases => ['Plot Four', 'Connect 4', "The Captain's Mistress"],
       :related => ['Connect6', 'Pente', 'KeryoPente', 'TicTacToe']

  attr_reader :board, :lastc, :lastp, :unused_moves

  def initialize_copy( original )
    super
    @unused_moves = original.unused_moves.map { |a| a.dup }
  end

  players [:red, :blue]

  @@init_moves = Coords.new( 7, 6 ).group_by { |c| c.x }.map do |sa|
    sa.map { |c| c.to_s }
  end

  def initialize( seed=nil )
    super

    @board = Board.new( 7, 6 )
    @lastc, @lastp = nil, :noone
    @unused_moves = @@init_moves.map { |a| a.dup }
  end

  def moves( player=nil )
    return [] unless player.nil? || has_moves.include?( player )
    return [] if final?
    unused_moves.map { |a| a.last }
  end

  def apply!( move )
    c, p = Coord[move], turn
    board[c], @lastc, @lastp = p, c, p
    unused_moves.each { |a| a.delete( c.to_s ) }
    unused_moves.delete( [] )
    turn( :rotate )
    self
  end

  def final?
    return false if lastc.nil?
    return true  if unused_moves.empty?

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
    board.empty_count == 0 &&
    board.each_from( lastc, [:e,:w] ) { |p| p == lastp } < 3 &&
    board.each_from( lastc, [:n,:s] ) { |p| p == lastp } < 3 &&
    board.each_from( lastc, [:ne,:sw] ) { |p| p == lastp } < 3 &&
    board.each_from( lastc, [:nw,:se] ) { |p| p == lastp } < 3
  end

  def hash
    [board, turn].hash
  end
end

