# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

# Three Musketeers is a simple board game with nonsymmetric objectives.  The
# red player wins by running out of moves.  The blue player wins by aligning
# all the red pieces on any single row or column.
#
# For detailed rules see:  http://vying.org/games/three_musketeers

Rules.create( "ThreeMusketeers" ) do
  name    "Three Musketeers"
  version "1.0.0"

  players :red, :blue

  can_move_to :red => :blue, :blue => nil

  cache :init, :moves

  position do
    attr_reader :board

    def init
      @board = Board.new( 5, 5 )
      @board[:a1,:b1,:c1,:d1,    
             :a2,:b2,:c2,:d2,:e2,
             :a3,:b3,    :d3,:e3,
             :a4,:b4,:c4,:d4,:e4,
                 :b5,:c5,:d5,:e5] = :blue

      @board[:a5,:c3,:e1] = :red
    end

    def moves
      return [] if red_in_a_line?

      men, p = board.occupied[turn], rules.can_move_to[turn]
      men.map { |c| capture_moves( c, p ) }.flatten!
    end

    def apply!( move )
      board.move( * move.to_coords )
      rotate_turn

      self
    end

    def final?
      moves.empty?
    end

    def winner?( player )
      bw = red_in_a_line?
      player == :red ? !bw : bw
    end

    def loser?( player )
      winner?( opponent( player ) )
    end

    def hash
      [board,turn].hash
    end

    private

    def red_in_a_line?
       board.occupied[:red].map { |c| c.x }.uniq.length == 1 ||
       board.occupied[:red].map { |c| c.y }.uniq.length == 1
    end

    def capture_moves( c, p )
      ns = board.coords.neighbors( c, [:n, :e, :w, :s] )
      ns.select { |n| board[n] == p }.map { |n| "#{c}#{n}" }
    end
  end

end

