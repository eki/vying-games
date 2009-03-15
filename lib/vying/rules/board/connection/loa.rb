# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

# Lines of Action.
#
# For detailed rules see:  http://vying.org/games/lines_of_action

Vying.rules( "LinesOfAction" ) do
  name    "Lines of Action"
  version "0.1.0"

  players :black, :white

  cache :init, :moves, :final?

  position do
    attr_reader :board, :counts

    def init
      @board = Board.square( 8, :plugins => [:connection] )
      @board[:a2,:a3,:a4,:a5,:a6,:a7] = :black
      @board[:h2,:h3,:h4,:h5,:h6,:h7] = :black
      @board[:b1,:c1,:d1,:e1,:f1,:g1] = :white
      @board[:b8,:c8,:d8,:e8,:f8,:g8] = :white

      @counts = {}
      init_counts
    end

    def moves
      return [] if final?

      a = []

      coords = board.occupied( turn )

      coords.each do |c|
        board.directions.each do |d|
           count = count( c, d )

           nc = c
           count.times do |i|
             nc = nc.next( d )

             unless (board[nc].nil? && board.in_bounds?( nc.x, nc.y )) ||
                    (board[nc] == turn && i+1 < count) || 
                    (board[nc] == opponent( turn ) && i+1 == count)
               break
             end

             if i+1 == count
               a << "#{c}#{nc}"
             end
           end
        end
      end

      a
    end

    def apply!( move )
      coords = move.to_coords

      capture = board[coords.last]

      board.move( coords.first, coords.last )

      counts[board.coords.row( coords.first )]          -= 1
      counts[board.coords.column( coords.first )]       -= 1
      counts[board.coords.diagonal( coords.first )]     -= 1
      counts[board.coords.diagonal( coords.first, -1 )] -= 1

      unless capture
        counts[board.coords.row( coords.last  )]          += 1
        counts[board.coords.column( coords.last  )]       += 1
        counts[board.coords.diagonal( coords.last  )]     += 1
        counts[board.coords.diagonal( coords.last,  -1 )] += 1
      end

      rotate_turn

      self
    end

    def final?
      players.any? { |p| board.groups[p].length <= 1 }
    end

    # Treat simultaneous connection as a draw.  For a long time this was the
    # accepted rule, until it was later changed by the designer.

    def winner?( player )
         board.groups[player].length <= 1 && 
      ! (board.groups[opponent( player )].length <= 1)
    end

    def draw?
      players.all? { |p| board.groups[p].length <= 1 }
    end

    def count( c, d )
      return counts[board.coords.row( c )]          if d == :e  || d == :w
      return counts[board.coords.column( c )]       if d == :n  || d == :s
      return counts[board.coords.diagonal( c )]     if d == :nw || d == :se
      return counts[board.coords.diagonal( c, -1 )] if d == :ne || d == :sw
    end

    private

    def init_counts
      b, cs = board, board.coords

      board.width.times do |i|
        c = Coord[i,0]
        counts[cs.column( c )] = b[*cs.column( c )].compact.length

        c = Coord[0,i]
        counts[cs.row( c )] = b[*cs.row( c )].compact.length

        # We force an array on the diagonals, since some diagonals are only
        # one element (eg, b[] doesn't return an array in that case

        c = Coord[i,0]
        counts[cs.diagonal( c, -1 )] = 
          [b[*cs.diagonal( c, -1 )]].flatten.compact.length

        c = Coord[i,0]
        counts[cs.diagonal( c )] = 
          [b[*cs.diagonal( c )]].flatten.compact.length

        c = Coord[i,b.height-1]
        counts[cs.diagonal( c, -1 )] = 
          [b[*cs.diagonal( c, -1 )]].flatten.compact.length

        c = Coord[i,b.height-1]
        counts[cs.diagonal( c )] = 
          [b[*cs.diagonal( c )]].flatten.compact.length
      end
    end

  end

end

