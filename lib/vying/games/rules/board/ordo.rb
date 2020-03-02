# frozen_string_literal: true

# Copyright 2008, Eric Idema, Dieter Stein except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying/games'

# Ordo
#
# For detailed rules see:  http://vying.org/games/ordo
# or the official website http://spielstein.com/games/ordo

Rules.create('Ordo') do
  name    'Ordo'
  version '0.5.0'

  players :white, :black

  cache :init, :moves

  position do
    attr_reader :board

    def init
      @board = Board.rect(10, 8)

      @board[ :c8, :d8, :g8, :h8,
             :a7, :b7, :c7, :d7, :e7, :f7, :g7, :h7, :i7, :j7,
             :a6, :b6,        :e6, :f6,        :i6, :j6] = :black

      @board[:a3, :b3,        :e3, :f3,        :i3, :j3,
             :a2, :b2, :c2, :d2, :e2, :f2, :g2, :h2, :i2, :j2,
                     :c1, :d1,        :g1, :h1 ] = :white

      @home_row = { white: 7, black: 0 }
      @finish   = Hash.new(false)
    end

    def has_moves
      return []  if @finish[opponent(turn)]
      return []  if board.occupied(turn).empty?

      [turn]
    end

    def moves
      connected = board.coords.connected?(board.occupied(turn))
      normal_moves(connected) + ordo_moves(connected)
    end

    def apply!(move)
      coords = move.to_coords

      if coords.length == 2

        # Normal move
        board.move(coords.first, coords.last)

      else

        # Ordo move
        sc = coords[0]
        dc = coords[2]
        h = coords[0].x - coords[1].x
        v = coords[0].y - coords[1].y

        loop do
          board.move(sc, dc)

          if h != 0
            break if sc.x == coords[1].x && dc.y == coords[2].y

            if coords[0].y == coords[1].y
              sc = board.coords.next(sc, h < 1 ? :e : :w)
              dc = board.coords.next(dc, h < 1 ? :e : :w)
            end
          end

          next unless v != 0
          break if sc.y == coords[1].y && dc.x == coords[2].x

          if coords[0].x == coords[1].x
            sc = board.coords.next(sc, v < 1 ? :s : :n)
            dc = board.coords.next(dc, v < 1 ? :s : :n)
          end
        end
      end

      @finish[turn] = coords.last.y == @home_row[opponent(turn)]
      rotate_turn
      self
    end

    def final?
      has_moves.empty?
    end

    def winner?(player)
      player != turn
    end

    private

    def normal_moves(connected)
      all = []
      if connected
        dirs = turn == :white ? [:s, :e, :w, :se, :sw] : [:n, :e, :w, :ne, :nw]
      else
        dirs = board.directions
      end

      pieces = board.occupied(turn)
      pieces.each do |c|
        dirs.each do |d|
          nc = c
          while (nc = board.coords.next(nc, d))

            # Can't move through your own pieces
            break if board[nc] == turn

            if pieces.size == 1 ||
                board.coords.connected?(pieces - [Coord[c]] + [Coord[nc]])
              all << "#{c}#{nc}"
            end

            # Stop move on occupied space
            break if board[nc]
          end
        end
      end

      all
    end

    def ordo_moves(connected)
      pieces = board.occupied(turn)
      return [] if pieces.size == 1

      all = []

      2.times do |d1|
        if d1 == 0
          # horizontal ordos move forwards (or backwards for rejoins)
          if connected
            d2 = turn == :white ? [:s] : [:n]
          else
            d2 = [:n, :s]
          end
          dd = :e

        else
          # Vertical ordos move left or right
          d2 = [:w, :e]
          dd = :n
        end

        d2.each do |d|
          # Find the next friendly piece
          pieces.each do |c|
            # Find all friendly neighbors
            nc = c
            neighbors = 0
            while nc = board.coords.next(nc, dd)
              break  if board[nc] != turn

              neighbors += 1
            end

            # No singleton ordos
            next if neighbors < 1

            # Steps the ordo could go
            fc = c
            while fc = board.coords.next(fc, d)
              break  if board[fc]

              # Now scan the row
              # first, make a step (no singleton ordos)
              from = [Coord[cc = c]]
              to = [Coord[ffc = fc]]
              neighbors.times do |n|
                ffc = board.coords.next(ffc, dd)

                # Found an empty space, valid ordo move?
                if board[ffc].nil?
                  from << Coord[cc = board.coords.next(cc, dd)]
                  to << Coord[ffc]
                  # Is the group still connected?
                  if board.coords.connected?(pieces - from + to)
                    all << "#{c}#{cc}#{fc}" << "#{cc}#{c}#{ffc}"
                  end
                else
                  neighbors = n
                  break
                end
              end
              break if neighbors < 1
            end
          end
        end
      end

      all
    end
  end
end
