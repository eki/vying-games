# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

# Yinsh
#
# For detailed rules see:  http://vying.org/games/yinsh

Rules.create( "Yinsh" ) do
  name    "YINSH"
  version "1.0.0"

  players :white, :black

  ring :white => :WHITE_RING,
       :black => :BLACK_RING

  score_determines_outcome

  cache :moves

  position do
    attr_reader :board, :removed, :rows, :removed_markers, :completed_row

    def init
      @board = YinshBoard.new
      @removed = { :WHITE_RING => 0, :BLACK_RING => 0 }
      @rows = []
      @removed_markers = []
      @completed_row = nil
    end

    def moves
      return [] if final?

      a = []

      rings = board.occupied[rules.ring[turn]]

      if rings.length < 5 && removed[rules.ring[turn]] == 0
        a = board.unoccupied

      elsif removed_markers.length == 5
        a = rings

      elsif ! rows.empty?
        if removed_markers.empty?
          prows = rows.select { |row| board[row.first] == turn }
        else
          prows = rows.select { |row| row.include?( removed_markers.first ) }
        end

        a = prows.flatten - removed_markers

      else
        rings.each do |r|
          YinshBoard::DIRECTIONS.each do |d|
            c, over_marker = r, false
            while c = board.coords.next( c, d )
              p = board[c]

              if p.nil?
                a << "#{r}#{c}"
                break if over_marker
              elsif p == :white || p == :black
                over_marker = true
              else
                break
              end
            end
          end

        end

      end

      a
    end

    def apply!( move )
      coords = move.to_coords

      if coords.length == 2
        # move the ring and put down a marker
        board.move( coords.first, coords.last )
        board[coords.first] = turn

        # flip markers
        all = [coords.first]
        d = coords.first.direction_to( coords.last )
        c = coords.first
        until (c = board.coords.next( c, d )) == coords.last
          all << c
          p = board[c]
          if p == :white || p == :black
            board[c] = p == :white ? :black : :white
          end
        end

        all << coords.last

        # check for five-in-a-row
        all.each do |c|
          p = board[c]

          if p == :white || p == :black
            [[:n,:s], [:e,:w], [:nw,:se]].each do |ds|
              row = [c]
              ds.each do |rd|
                c2 = c
                while c2 = board.coords.next( c2, rd )
                  p2 = board[c2]
                  break if p2 != p
                  row << c2
                end
              end
              rows << row if row.length >= 5
            end

          end
        end

        # handle butted overlines
        if rows.length > 1
          rows.each do |row|
            if row.length > 5   # overline
              row.sort!

              extra, i = row.length - 5, 0 
              until i == extra
                c = row[i]
                if rows.any? { |r2| r2.length == 5 && r2.include?( c ) }
                  row.slice!( 0, i+1 )
                  break
                end

                c = row[-i]
                if rows.any? { |r2| r2.length == 5 && r2.include?( c ) }
                  row.slice!( row.length - 1 - i, i+1 )
                  break
                end

                i += 1
              end

            end
          end
        end

        # separate overlines
        rows.each do |row|
          if row.length > 5
            row.sort!
            extra, i = row.length - 5, 0
            until i == extra
              rows << row[i,5]
              i += 1
            end
            row.slice!( 0, extra )
          end
        end

        @completed_row = turn unless rows.empty?

        rotate_turn  unless rows.any? { |row| board[row.first] == turn }

      elsif coords.length == 1
        rings = board.occupied[rules.ring[turn]]
  
        # add a ring to the board
        if rings.length < 5 && removed[rules.ring[turn]] == 0
          board[coords.first] = rules.ring[turn]
          rotate_turn

        # remove a ring from the board
        elsif removed_markers.length == 5
          removed[board[coords.first]] += 1
          board[coords.first] = nil
          rows.reject! { |row| row.sort == removed_markers.sort }
          removed_markers.clear
          if rows.empty?
            rotate_turn if turn == completed_row
            @completed_row = nil
          else
            rotate_turn unless rows.any? { |row| board[row.first] == turn }
          end

        # remove a marker
        elsif ! rows.empty?
          board[coords.first] = nil
          removed_markers << coords.first

          # reject entire rows that can no longer complete a 5-in-a-row
          rows.reject! do |row|
              removed_markers.any? { |c| row.include?( c ) } &&
            ! removed_markers.all? { |c| row.include?( c ) }
          end

          # reject empty rows
          rows.reject! { |row| row.empty? }

        end

      end

      self
    end

    def final?
      players.any? { |p| score( p ) == 3 } || markers_remaining == 0
    end

    def score( player )
      removed[rules.ring[player]]
    end

    def hash
      [board,removed,rows,removed_markers,turn].hash
    end

    def markers_remaining
      51 - board.count( :white ) - board.count( :black )
    end
  end

end

