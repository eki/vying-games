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
      @board = Board.square( 5, :directions => [:n, :e, :w, :s], 
                                :fill       => :blue )

      @board[:a5,:c3,:e1] = :red
    end

    def has_moves
      return []     if red_in_a_line?

      board.occupied( turn ).any? { |c| can_move?( c ) } ? [turn] : []
    end

    def moves
      return [] if red_in_a_line?

      board.occupied( turn ).map { |c| moves_for( c ) }.flatten!
    end

    def apply!( move )
      board.move( * move.to_coords )
      rotate_turn

      self
    end

    def final?
      has_moves.empty?
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
       board.occupied( :red ).map { |c| c.x }.uniq.length == 1 ||
       board.occupied( :red ).map { |c| c.y }.uniq.length == 1
    end

    def can_move?( c )
      p = rules.can_move_to[board[c]]     
      ns = board.coords.neighbors( c )
      ns.any? { |n| board[n] == p }
    end

    def moves_for( c )
      p = rules.can_move_to[board[c]]     
      ns = board.coords.neighbors( c )
      ns.select { |n| board[n] == p }.map { |n| "#{c}#{n}" }
    end
  end

end

