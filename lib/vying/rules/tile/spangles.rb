# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

# Spangles is a game using triangle shaped tiles.  It was designed by David
# Smith.
#
# For detailed rules see:  http://vying.org/games/spangles

Rules.create( "Spangles" ) do
  name    "Spangles"
  version "0.1.0"

  players :black, :white

  position do
    attr_reader :board, :last
    ignore :last

    def init
      @board = Board.infinite( :plugins => [:frontier] )
      @board[0,0] = :white
      @last = Coord[0,0]
    end

    def moves
      board.frontier
    end

    def apply!( move )
      board[move] = turn
      @last = move

      rotate_turn
      self
    end

    def final?
      players.any? { |p| winner?( p ) }
    end

    def winner?( p )
      check = [@last] + board.coords.neighbors( @last )

      check.any? do |c|
        board[c] && board.coords.neighbors( c ).all? { |nc| board[nc] == p }
      end && turn != p
    end

    def loser( p )
      winner?( opponent( p ) )
    end
  end

end

