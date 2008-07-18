# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

# Breakthrough is a where each player races to push his pawns across the
# board.  Plays sort of like a hybrid of Chess and Checkers.
#
# For detailed rules, etc:  http://vying.org/games/breakthrough

Rules.create( "Breakthrough" ) do
  name    "Breakthrough"
  version "1.0.0"

  players :black, :white

  position do
    attr_reader :board

    def init
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

    def apply!( move, player )
      coords = move.to_coords

      board.move( coords.first, coords.last )

      rotate_turn

      rotate_turn if moves.empty?

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
      16 - board.occupied[opponent( player )].length
    end

    def hash
      [board,turn].hash
    end
  end

end

