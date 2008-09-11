# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

Rules.create( "Connect4" ) do
  name    "Connect Four"
  version "1.0.0"

  players :red, :blue

  init_moves( Coords.new( 7, 6 ).group_by { |c| c.x }.map do |sa|
     sa.map { |c| c.to_s }
  end )

  position do
    attr_reader :board, :unused_moves
    ignore :unused_moves

    def init
      @board = Board.rect( :width => 7, :height => 6, :plugins => [:in_a_row] )

      @board.window_size = 4
      @unused_moves = rules.init_moves.map { |a| a.dup }
    end

    def moves
      return [] if final?
      unused_moves.map { |a| a.last }
    end

    def apply!( move )
      board[move] = turn
      unused_moves.each { |a| a.delete( move.to_s ) }
      unused_moves.delete( [] )
      rotate_turn
      self
    end

    def final?
      board.unoccupied.empty? || board.threats.any? { |t| t.degree == 0 }
    end

    def winner?( player )
      board.threats.any? { |t| t.degree == 0 && t.player == player }
    end

    def loser?( player )
      winner?( opponent( player ) )
    end

    def draw?
      board.unoccupied.empty? && ! board.threats.any? { |t| t.degree == 0 }
    end

    def hash
      [board, turn].hash
    end
  end

end

