# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

# Lines of Action.
#
# For detailed rules see:  http://vying.org/games/lines_of_action

Rules.create( "LinesOfAction" ) do
  name    "Lines of Action"
  version "0.1.0"

  players :black, :white

  position do
    attr_reader :board, :counts
    ignore :final_cache

    def init
      @board = Board.new( 8, 8 )
      @board[:a2,:a3,:a4,:a5,:a6,:a7] = :black
      @board[:h2,:h3,:h4,:h5,:h6,:h7] = :black
      @board[:b1,:c1,:d1,:e1,:f1,:g1] = :white
      @board[:b8,:c8,:d8,:e8,:f8,:g8] = :white

      @counts = {}
      @final_cache = false
      init_counts
    end

    def moves( player=nil )
      return [] unless player.nil? || has_moves.include?( player )
      return []     if final?
      a = []

      coords = board.occupied[turn]

      coords.each do |c|
        [:n,:e,:w,:s,:ne,:nw,:se,:sw].each do |d|
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

    def apply!( move, player=nil )
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

      @final_cache = nil

      self
    end

    def final?
      return @final_cache unless @final_cache.nil?

      players.each do |p|
        coords = board.occupied[p].dup
        return @final_cache = true if all_connected?( coords )
      end

      return @final_cache = false
    end

    # If both players are simultaneously connected the game should end
    # with the player who just moved as the winner

    def winner?( player )
      coords = board.occupied[player].dup
      if all_connected?( coords )
        turn != player || 
        ! all_connected?( board.occupied[opponent( player )].dup )
      end
    end

    def loser?( player )
      ! winner?( player )
    end

    def hash
      [board,turn].hash
    end

    def all_connected?( coords )
      all, check = {}, [coords.first]

      while c = check.pop
        coords.delete c

        board.coords.neighbors( c ).each do |nc|
          check << nc if coords.include?( nc )
        end
      end

      coords.empty?
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

