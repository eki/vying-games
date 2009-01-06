# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

# Dodgem.
#
# For detailed rules, etc:  http://vying.org/games/dodgem

Rules.create( "Dodgem" ) do
  name    "Dodgem"
  version "0.5.0"

  players :blue, :red

  option :board_size, :default => 4, :values => (3..5).to_a

  move_directions :blue => [:e, :n, :s],
                  :red  => [:n, :e, :w]

  position do
    attr_reader :board

    def init
      length = @options[:board_size]

      @board = Board.square( length + 1, :directions => [:n, :e, :w, :s] )

      (length - 1).times do |i|
        @board[0,i+1] = :blue
        @board[i + 1,length] = :red
      end
    end

    def has_moves
      board.occupied( turn ).each do |c|
        board.coords.neighbors( c, rules.move_directions[turn] ).each do |nc|
          return [turn]  if board[nc].nil? && can_land_on?( nc, turn )
        end
      end

      []
    end

    def moves
      found = []

      board.occupied( turn ).each do |c|
        board.coords.neighbors( c, rules.move_directions[turn] ).each do |nc|
          found << "#{c}#{nc}"  if board[nc].nil? && can_land_on?( nc, turn )
        end
      end

      found
    end

    def apply!( move )
      coords = move.to_coords

      if off_board?( coords.last, turn )
        board[coords.first] = nil
      else
        board.move( coords.first, coords.last )
      end

      rotate_turn

      self
    end

    def final?
      has_moves.empty?
    end

    def winner?( player )
      turn == player
    end

    def loser?( player )
      turn != player
    end

    def off_board?( c, player )
      (player == :blue && c.x == board.width - 1) ||
      (player == :red  && c.y == 0)
    end

    def can_land_on?( c, player )
      (player == :blue && c.y != 0) ||
      (player == :red  && c.x != board.width - 1)
    end
  end
end

