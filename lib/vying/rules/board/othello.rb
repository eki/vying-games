# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

Rules.create( "Othello" ) do
  name    "Othello"
  version "1.0.0"
  notation :othello_notation

  players :black, :white

  score_determines_outcome

  cache :moves

  position do
    attr_reader :board

    def init
      @board = OthelloBoard.new
    end

    def move?( move )
      cs = move.to_coords

      board.valid?( cs.first, turn ) unless cs.length != 1
    end

    def moves
      board.frontier.select { |c| board.valid?( c, turn ) }
    end

    def apply!( move )
      board.place( move.to_coords.first, turn )

      rotate_turn

      if moves.empty?
        rotate_turn
        clear_cache
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

