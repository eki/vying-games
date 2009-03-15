# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

Rules.create( "Yavalath" ) do
  name    "Yavalath"
  version "0.5.0"

  players :white, :black, :red
  option :number_of_players, :default => 2, :values => [2, 3]

  position do
    attr_reader :board
  
    def init
      @board = Board.hexagon( 5, :plugins => [:in_a_row] )
      @board.window_size = 4
    end

    def moves
      return []  if final?
      
      if @options[:number_of_players] == 3
        forced = forced_moves
        return forced  unless forced.empty?
      end

      board.unoccupied
    end

    def apply!( move )
      board[move] = turn
      rotate_turn
      self
    end

    def final?
      board.unoccupied.empty? || players.any? { |p| four_in_a_row?( p ) } ||
      players.select { |p| three_in_a_row?( p ) }.length == players.length - 1
    end

    def winner?( player )
      four_in_a_row?( player ) || 
      (! (players - [player]).any? { |p| four_in_a_row?( p ) } &&
       ! three_in_a_row?( player ) &&
       players.select { |p| three_in_a_row?( p ) }.length == players.length - 1)
    end

    def draw?
      board.unoccupied.empty? && ! board.threats.any? { |t| t.degree == 0 }
    end

    private

    def four_in_a_row?( player )
      ts = board.threats.select { |t| t.player == player }
      ts.any? { |t| t.degree == 0 }
    end

    def three_in_a_row?( player )
      ts = board.threats.select { |t| t.player == player }
      ts.any? { |t| t.degree == 1 && board.coords.connected?( t.occupied ) }
    end

    def forced_moves
      ts = board.threats.select { |t| t.player != turn }
      ts = ts.select { |t| t.degree == 1 && 
                           ! board.coords.connected?( t.occupied ) }
      ts.map { |t| t.empty_coords }
    end
  end

end

