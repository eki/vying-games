# Copyright 2008, Eric Idema, Dieter Stein except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

# Phalango
#
# For detailed rules see:  http://vying.org/games/phalango
# or the official website http://spielstein.com/games/phalango

Rules.create( "Phalango" ) do
  name    "Phalango"
  version "1.0.0"

  players :white, :black
  option :board_size, :default => 6, :values => [4, 6, 8]

  cache :init, :moves

  position do
    attr_reader :board

    def init
      length = @options[:board_size]
      center = length / 2

      @board = Board.square( length, :plugins => [:connection] )
      @baseline = {
        :white => (0...length).collect { |x| Coord[x, 0].to_sym },
        :black => (0...length).collect { |x| Coord[x, length-1].to_sym }
      }
      length.times do |x|
        length.times do |y|
          board[Coord[x,y]] = y < center ? :white : :black
        end
      end
      @connected = Hash.new( true )
    end

    def has_moves
      return []  unless @connected[opponent( turn )]
      return []  if @baseline[turn].any? { |c| board[c] == opponent( turn ) }
      return []  if board.occupied( turn ).empty?

      [turn]
    end

    def moves
      all = []
      pieces = board.occupied( turn )
      pieces.each do |c|
        board.directions.each do |d|
          nc = c
          while (nc = board.coords.next( nc, d ))
            break if board[nc] == turn

            if ! board.coords.neighbors( nc ).any? { |nnc| board[nnc] == turn }
              next
            end

            if board.coords.connected?( pieces - [Coord[c]] + [Coord[nc]] )
              all << "#{c}#{nc}"
              break unless board[nc].nil?
            end
          end
        end
      end
      all
    end

    def apply!( move )
      coords = move.to_coords
      board.move( coords.first, coords.last )
      @connected[turn] = board.coords.connected?( board.occupied( turn ) )

      rotate_turn
      self
    end

    def final?
      has_moves.empty?
    end

    def winner?( player )
      @baseline[opponent( player )].any? { |c| board[c] == player }
    end
    
    def loser?( player )
      winner?( opponent( player ) )
    end

  end

end

