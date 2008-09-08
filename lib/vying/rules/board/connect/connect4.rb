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
    attr_reader :board, :lastc, :lastp, :unused_moves
    ignore :lastc, :lastp, :unused_moves

    def init
      @board = Board.new( :shape => :rect, :width => 7, :height => 6 )
      @lastc, @lastp = nil, :noone
      @unused_moves = rules.init_moves.map { |a| a.dup }
    end

    def moves
      return [] if final?
      unused_moves.map { |a| a.last }
    end

    def apply!( move )
      c, p = Coord[move], turn
      board[c], @lastc, @lastp = p, c, p
      unused_moves.each { |a| a.delete( c.to_s ) }
      unused_moves.delete( [] )
      rotate_turn
      self
    end

    def final?
      return false if lastc.nil?
      return true  if unused_moves.empty?

      board.each_from( lastc, [:e,:w] ) { |p| p == lastp } >= 3 ||
      board.each_from( lastc, [:n,:s] ) { |p| p == lastp } >= 3 ||
      board.each_from( lastc, [:ne,:sw] ) { |p| p == lastp } >= 3 ||
      board.each_from( lastc, [:nw,:se] ) { |p| p == lastp } >= 3
    end

    def winner?( player )
      board.each_from( lastc, [:e,:w] ) { |p| p == player } >= 3 ||
      board.each_from( lastc, [:n,:s] ) { |p| p == player } >= 3 ||
      board.each_from( lastc, [:ne,:sw] ) { |p| p == player } >= 3 ||
      board.each_from( lastc, [:nw,:se] ) { |p| p == player } >= 3
    end

    def loser?( player )
      !draw? && player != lastp
    end

    def draw?
      board.empty_count == 0 &&
      board.each_from( lastc, [:e,:w] ) { |p| p == lastp } < 3 &&
      board.each_from( lastc, [:n,:s] ) { |p| p == lastp } < 3 &&
      board.each_from( lastc, [:ne,:sw] ) { |p| p == lastp } < 3 &&
      board.each_from( lastc, [:nw,:se] ) { |p| p == lastp } < 3
    end

    def hash
      [board, turn].hash
    end
  end

end

