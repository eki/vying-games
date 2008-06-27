# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

# Amazons is a territory game.  With every move the playable area of the
# game board is reduced.  Each player tries to claim more territory so they
# can outlast their opponent.
#
# For detailed rules see:  http://vying.org/games/amazons

Rules.create( "Amazons" ) do
  name    "Amazons"
  version "1.0.0"

  players :white, :black

  position do
    attr_reader :board, :lastc

    def init
      @board, @lastc = AmazonsBoard.new, nil
    end

    def move?( move, player=nil )
      return false unless player.nil? || has_moves.include?( player )
      return false if final?

      cs = move.to_coords
      return false unless cs.length == 2

      queens = board.occupied[turn]

      return false unless queens.include?( cs.first )
      return false unless d = cs.first.direction_to( cs.last )

      ic = cs.first
      while (ic = board.coords.next( ic, d ))
        return false if !board[ic].nil?
        break        if ic == cs.last
      end

      return true
    end

    def moves( player=nil )
      return []          unless player.nil? || has_moves.include?( player )

      a = []

      queens = board.occupied[turn]

      if lastc.nil? || board[lastc] == :arrow
        queens.each do |q|
          board.mobility[q].each { |ec| a << "#{q}#{ec}" }
        end
      else
        board.mobility[lastc].each { |ec| a << "#{lastc}#{ec}" }
      end

      a
    end

    def apply!( move, player=nil )
      coords = move.to_coords

      if lastc.nil? || board[lastc] == :arrow
        board.move( coords.first, coords.last )
      else
        board.arrow( coords.last )
        rotate_turn
      end

      @lastc = coords.last 

      self
    end

    def final?
      moves.empty?
    end

    def winner?( player )
      player != turn
    end

    def loser?( player )
      player == turn
    end

    def score( player )
      board.territory( player ).length
    end

    def hash
      [board,turn].hash
    end
  end

end

