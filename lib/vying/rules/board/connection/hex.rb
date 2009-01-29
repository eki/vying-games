# Copyright 2007-08, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

# Hex
#
# For detailed rules see:  http://vying.org/games/hex

Rules.create( "Hex" ) do
  name    "Hex"
  version "0.1.0"

  players :red, :blue

  option :board_size, :default => 11, :values => (9..19).to_a

  pie_rule

  cache :moves

  position do
    attr_reader :board

    def init
      length = @options[:board_size]
      @board = Board.rhombus( length, length, :plugins => [:connection] )
    end

    def moves
      return []  if final?

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
      case player
        when :red
          board.groups[player].any? do |group|
            group.coords.any? { |c| c.y == 0 } &&
            group.coords.any? { |c| c.y == board.height - 1 }
          end
        when :blue
          board.groups[player].any? do |group|
            group.coords.any? { |c| c.x == 0 } &&
            group.coords.any? { |c| c.x == board.width - 1 }
          end
      end
    end
  end

end

