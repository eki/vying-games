# Copyright 2008, Eric Idema, Dieter Stein except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

# Ordo
#
# For detailed rules see:  http://vying.org/games/ordo
# or the official website http://spielstein.com/games/ordo

Rules.create( "Ordo" ) do
  name    "Ordo"
  version "0.2.0"

  players :white, :black

  cache :init, :moves

  position do
    attr_reader :board

    def init
      @board = Board.rect( 10, 8 )

      @board[        :c8,:d8,        :g8,:h8,
             :a7,:b7,:c7,:d7,:e7,:f7,:g7,:h7,:i7,:j7,
             :a6,:b6,        :e6,:f6,        :i6,:j6] = :black

      @board[:a3,:b3,        :e3,:f3,        :i3,:j3,
             :a2,:b2,:c2,:d2,:e2,:f2,:g2,:h2,:i2,:j2,
                     :c1,:d1,        :g1,:h1        ] = :white

      @home_row   = { :white => 0, :black => 7 }
      @last       = nil
      @finished   = false
      @directions = { :white => [:s, :e, :w, :se, :sw],
                      :black => [:n, :e, :w, :ne, :nw] }
      
      @disconnected = false
      @permanently_disconnected = false
    end

    def has_moves
      return []  if @permanently_disconnected
      return []  if @last && @last.y == @home_row[opponent( turn )]
      return []  if board.occupied( turn ).empty?

      [turn]
    end

    def moves
      if @disconnected
        rejoin_moves + ordo_moves( true )
      else
        normal_moves + ordo_moves( false )
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
        @directions[ turn ].each do |d|
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

    # 
    # TODO
    # Still only *vertical* ordo moves implemented!
    # 
    def ordo_moves( rejoin )
      all = []
      
      # horizontal ordo lines move forwards (or backwards for rejoins)
      # directions = rejoin ? [:n, :s] : (turn == :white ? [:s] : [:n])
      dir = turn == :white ? :s : :n
      
      # Find the next friendly piece
      friendly_pieces = board.occupied( turn )
      friendly_pieces.each do |c|

        # Find all friendly neighbors to the east
        nc = c
        neighbors = 0
        while( nc = board.coords.next( nc, :e ))
          break  if board[nc] != turn
          neighbors += 1
        end

        # No singleton ordos
        next  if neighbors < 1

        # Steps the ordo could go
        fc = c
        while( fc = board.coords.next( fc, dir ))
          break  if board[fc]
          
          # Now scan the row to the east
          # first, make a step (no singleton ordos)
          cc = c
          from = [Coord[cc]]
          ffc = fc
          to   = [Coord[ffc]]
          neighbors.times do |n|
            ffc = board.coords.next( ffc, :e )

            # Found an empty space, valid ordo move?
            if board[ffc].nil?
              from << Coord[cc = board.coords.next( cc, :e )]
              to   << Coord[ffc]
              # Is the group still connected?
              if board.coords.connected?( friendly_pieces - from + to )
                all << "#{c}#{cc}#{fc}" << "#{cc}#{c}#{ffc}"
              end
            else
              neighbors = n
              break
            end
          end
          break  if neighbors < 1
        end

      end
      all
    end

  end

end

