# Copyright 2008, Eric Idema, Dieter Stein except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

# Phalango
#
# For detailed rules see:  http://vying.org/games/phalango
# or the official website http://spielstein.com/games/phalango

Rules.create( "Phalango" ) do
  name    "Phalango"
  version "0.9.0"

  players :white, :black
  option :board_size, :default => 6, :values => [4, 6, 8]

  cache :init, :moves

  position do
    attr_reader :board

    def init
      length = @options[:board_size]
      center = length / 2

      @board = Board.square( length )

      length.times do |x|
        length.times do |y|
          board[Coord[x,y]] = y < center ? :white : :black
        end
      end

      @baseline     = { :white => 0, :black => length-1 }
      @last         = nil
      @finished     = false

      @disconnected = false
      @permanently_disconnected = false
    end

    def has_moves
      return []  if @permanently_disconnected
      return []  if @last && @last.y == @baseline[opponent( turn )]
      return []  if board.occupied( turn ).empty?

      [turn]
    end

    def moves
      if @disconnected
        rejoin_moves
      else
        normal_moves
      end
    end

    def apply!( move )
      coords = move.to_coords
      op = board[coords.last]

      board.move( coords.first, coords.last )

      @disconnected = false
      @last = coords.last

      rotate_turn

      # Determine if this move disconnected the opponent... hence requiring
      # a reconnect move (if one exists, or the game has ended)

      if op == turn && ! safe_to_remove?( @last, turn ) 
        @disconnected = true

        @permanently_disconnected = true  if moves.empty?
      end

      self
    end

    def final?
      has_moves.empty?
    end

    def winner?( player )
      player != turn
    end
    
    private

    def safe_to_remove?( c, p )
      ns = board.coords.neighbors( c ).select { |nnc| board[nnc] == p }
      groups = board.group_by_connectivity( ns )

      groups.length == 1 || 
      groups.inject { |g1,g2| g1 ? 
        (board.path?( g1.first, g2.first ) ? g2 : nil) : nil }
    end

    def normal_moves
      all = []

      board.occupied( turn ).each do |c|
        board.directions.each do |d|
          nc = c

          # A starting coord (c) is only valid if it does *not* cause a
          # disconnect

          valid_start = nil

          while (nc = board.coords.next( nc, d ))

            # Can't move through your own pieces

            break  if board[nc] == turn

            # Can't land on a square that doesn't have any neighbors 
            # occupied by your own pieces (obvious disconnect)

            ns = board.coords.neighbors( nc )
            next  unless ns.any? { |nnc| nnc != c && board[nnc] == turn }

            valid_start = safe_to_remove?( c, turn )  if valid_start.nil?

            break  unless valid_start

            all << "#{c}#{nc}"
            break  if board[nc]
          end

        end
      end

      all
    end

    def rejoin_moves
      all, pieces = [], board.occupied( turn )

      pieces.each do |c|
        board.directions.each do |d|
          nc = c

          while (nc = board.coords.next( nc, d ))

            # Can't move through your own pieces

            break  if board[nc] == turn

            # Can't land on a square that doesn't have any neighbors 
            # occupied by your own pieces (obvious disconnect)

            ns = board.coords.neighbors( nc )
            next  unless ns.any? { |nnc| nnc != c && board[nnc] == turn }

            if board.coords.connected?( pieces - [Coord[c]] + [Coord[nc]] )
              all << "#{c}#{nc}"
              break  if board[nc]
            end
          end
        end
      end

      all
    end

  end

end

