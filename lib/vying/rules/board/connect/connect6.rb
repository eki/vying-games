# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

Rules.create( "Connect6" ) do
  name    "Connect6"
  version "1.0.0"

  players :black, :white

  allow_draws_by_agreement

  position do
    attr_reader :board

    def init
      @board = Connect6Board.new
      @turn = [:black, :white, :white, :black]
    end

    def moves( player=nil )
      return [] unless player.nil? || has_moves.include?( player )
      return [] if final?
      board.unoccupied
    end

    def apply!( move, player=nil )
      c, p = Coord[move], turn
      board[c] = p
      board.update_threats( c )
      rotate_turn
      self
    end

    def final?
      board.unoccupied.empty? ||
      board.threats.any? { |t| t.degree == 0 }
    end

    def winner?( player )
      board.threats.any? { |t| t.degree == 0 && t.player == player }
    end

    def loser?( player )
      winner?( opponent( player ) )
    end

    def draw?
      board.unoccupied.empty? &&
      ! board.threats.any? { |t| t.degree == 0 }
    end

    def hash
      [board,turn].hash
    end
  end

end

