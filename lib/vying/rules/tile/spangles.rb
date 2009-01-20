# Copyright 2008, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

# Spangles is a game using triangle shaped tiles.  It was designed by David
# Smith.
#
# For detailed rules see:  http://vying.org/games/spangles

Rules.create( "Spangles" ) do
  name    "Spangles"
  version "0.5.0"

  players :black, :white

  cache :final?

  position do
    attr_reader :board, :last
    ignore :last

    def init
      @board = Board.infinite( :plugins => [:frontier], 
                               :cell_shape => :triangle )
      @board[0,0] = :white
      @last = Coord[0,0]
    end

    def moves
      return []  if final?

      board.frontier.map { |c| c.to_s( false ) }
    end

    def apply!( move )
      @last = Coord[move]

      board[@last] = turn

      rotate_turn
      self
    end

    def final?
      players.any? { |p| winner?( p ) }
    end

    def winner?( player )
      ns = board.coords.neighbors( @last )

      first  = surrounded?( @last )
      second = ns.map { |nc| surrounded?( nc ) }.find { |np| np }

      return player != turn    if first && second 
      return player == first   if first
      return player == second  if second

      false
    end

    # Returns the color of the surrounding triangles if they are all the same.
    # Otherwise, returns nil.  Note:  Expects the given coord to be occupied,
    # if it isn't, nil is returned.

    def surrounded?( c )
      return nil  if board[c].nil?

      nps = board.coords.neighbors( c ).map { |nc| board[nc] }.compact
      
      nps.length == 3 && nps.uniq.length == 1 ? nps.first : nil
    end
  end

end

