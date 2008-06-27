# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

Rules.create( "Othello" ) do
  name    "Othello"
  version "1.0.0"
  notation :othello_notation

  players :black, :white

  score_determines_outcome

  position do
    attr_reader :board, :moves_cache
    ignore :moves_cache

    def init
      @board = OthelloBoard.new
      @moves_cache = :ns
    end

    def move?( move, player=nil )
      return false unless player.nil? || has_moves.include?( player )
      cs = move.to_coords

      board.valid?( cs.first, turn ) unless cs.length != 1
    end

    def moves( player=nil )
      return []          unless player.nil? || has_moves.include?( player )
      return moves_cache if moves_cache != :ns

      a = board.frontier.select { |c| board.valid?( c, turn ) }
      @moves_cache = a.map { |c| c.to_s }
    end

    def apply!( move, player=nil )
      c = Coord[move]
      board.place( c, turn )

      rotate_turn
      @moves_cache = :ns

      if moves.empty?
        rotate_turn
        @moves_cache = :ns
      end

      self
    end

    def final?
      moves.empty?
    end

    def score( player )
      board.count( player )
    end

    def hash
      [board, turn].hash
    end
  end

end

