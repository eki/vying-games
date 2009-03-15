# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

# Hexplode.
#
# For detailed rules, etc:  http://vying.org/games/hexplode

Vying.rules( "Hexplode" ) do
  name    "Hexplode"
  version "0.5.0"

  players :red, :blue

  cache :moves

  position do
    attr_reader :board

    def init
      @board = Board.rhombus( 5, 5 )
    end

    def moves
      return [] if final?

      board.coords.select { |c| board[c].nil? || board[c].player == turn }
    end

    def apply!( move )
      c = Coord[move]

      if board[c].nil?
        board[c] = Counter[turn, 1]
      else
        board[c] += 1
      end

      explode( c )  # has no effect if the cell isn't at capacity

      rotate_turn

      self
    end

    def final?
      players.any? { |p| winner?( p ) }
    end

    def winner?( player )
      opp = opponent( player )

      opp == turn && board.count > 1 &&
      ! board.coords.any? { |c| board[c] && board[c].player == opp }
    end

    def score( player )
      board.coords.inject( 0 ) do |s,c| 
        s + (board[c] && board[c].player == player ? board[c].count : 0)
      end
    end

    # This method is recursive, and cuts off immediately if a chain reaction
    # has touched every cell on the board.  This might leave the board / score
    # in an undefined state, but the game will be final because touching every
    # cell will force a wipe out.

    def explode( c, touched=[c] )
      return          if touched.length == board.coords.length
      touched << c    unless touched.include?( c )

      ns = board.coords.neighbors( c )

      return          if board[c].nil? || board[c].count < ns.length

      board[c] -= ns.length

      ns.each do |nc| 
        if board[nc]
          board[nc] = Counter[board[c].player, board[nc].count+1] 
        else
          board[nc] = Counter[board[c].player, 1]
        end
      end

      ns.each { |nc| explode( nc, touched ) } 

      board[c] = nil  if board[c] && board[c].count == 0
    end
  end

end

