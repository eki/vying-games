# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

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

  def moves( player=nil )
    return [] unless player.nil? || has_moves.include?( player )
    return [] if final?

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
        found << "#{c}#{c1}" unless c1.nil? || p1 == turn
      end
    end

    found
  end

  def apply!( move )
    coords = move.to_coords

    board.move( coords.first, coords.last )

    turn( :rotate )

    turn( :rotate ) if moves.empty?

    self
  end

  def final?
    board[:a1, :b1, :c1, :d1, :e1, :f1, :g1, :h1].include?( :white ) ||
    board[:a8, :b8, :c8, :d8, :e8, :f8, :g8, :h8].include?( :black ) 
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

  def score( player )
    opp = player == :black ? :white : :black
    16 - board.occupied[opp].length
  end

  def hash
    [board,turn].hash
  end

end

