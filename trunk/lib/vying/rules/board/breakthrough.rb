require 'vying/rules'
require 'vying/board/board'

class Breakthrough < Rules

  info :name      => 'Breakthrough',
       :resources => 
         ['Wikipedia <http://en.wikipedia.org/wiki/Breakthrough_(board_game)>']

  attr_reader :board

  players [:black, :white]

  def initialize( seed=nil )
    super

    @board = Board.new( 8, 8 )

    @board[:a1,:b1,:c1,:d1,:e1,:f1,:g1,:h1,         
           :a2,:b2,:c2,:d2,:e2,:f2,:g2,:h2] = :black

    @board[:a7,:b7,:c7,:d7,:e7,:f7,:g7,:h7,
           :a8,:b8,:c8,:d8,:e8,:f8,:g8,:h8] = :white
  end

  def op?( op, player=nil )
    return false unless player.nil? || has_ops.include?( player )
    !final? && ops.include?( op.to_s )
  end

  def ops( player=nil )
    return false unless player.nil? || has_ops.include?( player )
    if board[:a1, :b1, :c1, :d1, :e1, :f1, :g1, :h1].include?( :white ) || 
       board[:a8, :b8, :c8, :d8, :e8, :f8, :g8, :h8].include?( :black ) 
      return false
    end

    opp  = (turn == :black) ? :white : :black

    found = []
  
    cds = { :white => [:ne, :nw], :black => [:se, :sw] }
    mds = { :white => [:n],       :black => [:s]       }

    board.occupied[turn].each do |c|
      mds[turn].each do |d|
        p1 = board[c1 = board.coords.next( c, d )]
        found << "#{c}#{c1}" if p1.nil? && ! c1.nil?
      end

      cds[turn].each do |d|
        p1 = board[c1 = board.coords.next( c, d )]
        found << "#{c}#{c1}" if p1 == opp && ! c1.nil?
      end
    end

    return found unless found.empty?

    false
  end

  def apply!( op )
    coords = op.to_coords

    board.move( coords.first, coords.last )

    turn( :rotate )

    turn( :rotate ) unless ops

    self
  end

  def final?
    board[:a1, :b1, :c1, :d1, :e1, :f1, :g1, :h1].include?( :white ) ||
    board[:a8, :b8, :c8, :d8, :e8, :f8, :g8, :h8].include?( :black ) ||
    ! ops
  end

  def winner?( player )
    (player == :white &&
     board[:a1, :b1, :c1, :d1, :e1, :f1, :g1, :h1].include?( :white ) ) ||
    (player == :black && 
     board[:a8, :b8, :c8, :d8, :e8, :f8, :g8, :h8].include?( :black ) )
  end

  def loser?( player )
    (player == :black &&
     board[:a1, :b1, :c1, :d1, :e1, :f1, :g1, :h1].include?( :white ) ) ||
    (player == :white && 
     board[:a8, :b8, :c8, :d8, :e8, :f8, :g8, :h8].include?( :black ) )
  end

  def draw?
    final? && ! players.any? { |p| winner?( p ) }
  end

  def hash
    [board,turn].hash
  end

end

