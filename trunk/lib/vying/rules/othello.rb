require 'vying/rules'
require 'vying/board/othello'

class Othello < Rules

  info :name    => 'Othello',
       :aliases => ['Reversi']

  attr_reader :board, :ops_cache

  players [:black, :white]

  def initialize( seed=nil )
    super

    @board = OthelloBoard.new
    @ops_cache = :ns
  end

  def frontier
    @board.frontier
  end

  def occupied
    @board.occupied
  end

  def op?( op, player=nil )
    return false unless player.nil? || has_ops.include?( player )
    board.valid?( Coord[op], turn )
  end

  def ops( player=nil )
    return false unless player.nil? || has_ops.include?( player )
    return ops_cache if ops_cache != :ns
    a = frontier.select { |c| board.valid?( c, turn ) }.map { |c| c.to_s }
    ops_cache = (a == [] ? nil : a)
  end

  def apply!( op )
    c = Coord[op]
    board.place( c, turn )

    turn( :rotate )
    @ops_cache = :ns
    return self if ops

    turn( :rotate )
    ops_cache = :ns

    self
  end

  def final?
    !ops
  end

  def winner?( player )
    opp = player == :black ? :white : :black
    board.count( player ) > board.count( opp )
  end

  def loser?( player )
    opp = player == :black ? :white : :black
    board.count( player ) < board.count( opp )
  end

  def draw?
    board.count( :white ) == board.count( :black )
  end

  def score( player )
    board.count( player )
  end

  def hash
    [board, turn].hash
  end
end

