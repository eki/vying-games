# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

# Y
#
# For detailed rules see:  http://vying.org/games/y

Rules.create( "Y" ) do
  name    "Y"
  version "1.0.0"

  players :blue, :red

  option :board_size, :default => 12, :values => [12, 13, 14]

  pie_rule

  cache :init, :moves

  position do
    attr_reader :board, :groups
    ignore :groups

    def init
      @board = Board.triangle @options[:board_size], :plugins => [:connection]
    end

    def moves
      board.unoccupied
    end

    def apply!( move )
      board[move] = turn
      rotate_turn
      self
    end

    def final?
      players.any? { |p| winner?( p ) }
    end

    def winner?( player )
      board.groups[player].any? do |group|
        group.coords.any? { |c| c.x == 0 } &&
        group.coords.any? { |c| c.y == 0 } &&
        group.coords.any? { |c| c.x + c.y == board.length - 1 } 
      end
    end

    def loser?( player )
      winner?( opponent( player ) )
    end
  end

end

