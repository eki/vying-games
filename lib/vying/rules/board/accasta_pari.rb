# Copyright 2008, Eric Idema, Dieter Stein except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

# Accasta Pari
#
# For detailed rules see:  http://vying.org/games/accasta_pari
# or the official Accasta site: http://accasta.com/rules/variants/pari

Rules.create( 'AccastaPari' ) do
  name     'Accasta Pari'
  version  '0.1.0'
# notation :accasta_pari_notation

  players :white, :black

  score_determines_outcome

  cache :moves

  position do
    attr_reader :board, :home, :lastc

    def init
      @board = Board.hexagon( 4, :plugins => [:stacking] )
      @home = {
          :white => [:a1,:b1,:c1,:d1,:b2,:c2,:d2,:c3,:d3],
          :black => [:d5,:e5,:d6,:e6,:f6,:d7,:e7,:f7,:g7]
      }
      @lastc = nil
      board[:a1, :b1, :c1, :d1] = [:white, :white, :white]
      board[:b2, :c2, :d2] = [:white, :white]
      board[:c3, :d3] = [:white]
      board[:d5, :e5] = [:black]
      board[:d6, :e6, :f6] = [:black, :black]
      board[:d7, :e7, :f7, :g7] = [:black, :black, :black]
   end

    def has_moves
      return [] if score( opponent( turn ) ) >= 3

      [turn]
    end

    def moves
      a = []

      # Already moved in this turn?
      if @lastc
        a += moves_from( @lastc )
        a << :pass
      else
        board.occupied.each do |c|
          a += moves_from( c )
        end
      end
      a
    end

    def apply!( move )
      if move.to_s == 'pass'
        @lastc = nil
        rotate_turn
      else
        length, coords = move[0..0].to_i, move[1..-1].to_coords
        board[coords.last] = board[coords.first][0...length] + board[coords.last].to_a
        board[coords.first] = board[coords.first][length..-1]
        board[coords.first] = nil if board[coords.first].empty?
        @lastc = coords.first
      end
      self
    end

    def final?
      has_moves.empty?
    end

    def score( player )
      count = 0
      home[opponent( player )].each do |c|
        count += 1 if board[c] && board[c].first == player
      end
      count
    end

    private

    def moves_from( coord )
      a = []
      if board[coord] && board[coord].first == turn

        # Number of own pieces in the stack determines range.
        range = (board[coord] - [opponent( turn )]).length
  
        # Number of pieces equals number of move options.
        # Take one from the top, then two pieces, etc...
        board[coord].length.times do |p|

          # The moving stack.
          mstack = board[coord][0..p]

          # Into all possible directions.
          board.directions.each do |d|
            nc, step = coord, 0

            # Still on the board?
            while (nc = board.coords.next( nc, d ))

              # If cell is empty then move, ...
              if board[nc].nil?
                a << "#{mstack.length}#{coord}#{nc}"

              # ... otherwise move and combine the two stacks.
              else
                nstack = mstack + board[nc]

                # Only if the number of pieces of one color is less or equal three.
                if ((nstack - [turn]).length <= 3) && ((nstack - [opponent( turn )]).length <= 3)
                  a << "#{mstack.length}#{coord}#{nc}"
                end
                
                # Next direction, ie. do not jump other pieces on the board.
                break
              end

              # Next step in current direction ...
              step += 1
               
              # ... up to the maximal range.
              break if step == range
            end
          end
        end
      end
      a
    end

  end
end
