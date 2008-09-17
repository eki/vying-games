# Copyright 2008, Eric Idema, Dieter Stein except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

# Attangle
#
# For detailed rules see:  http://vying.org/games/attangle
# or the official Attangle site: http://attangle.com

Rules.create( 'Attangle' ) do
  name     'Attangle'
  version  '1.0.0'
  notation :attangle_notation

  players :white, :black
  option :board_size, :default => 4, :values => Array( 3..6 )

  score_determines_outcome

  cache :moves

  position do
    attr_reader :board, :pool, :triples

    def init
      length   = @options[:board_size]

      @board   = Board.hexagon( length, :plugins => [:stacking] )
      @pool    = Hash.new( initial_pool( length ) )
      @triples = required_triples( length )
      @center  = center( length )
    end

    def has_moves
      return []      if score( opponent( turn ) ) == triples
      return [turn]  if pool[turn] > 0
      return [turn]  if capture_moves.any?

      []
    end

    def moves
      all = []
      all += board.unoccupied - [@center] if pool[turn] > 0
      all += capture_moves
    end

    def apply!( move )
      coords = move.to_coords
      if coords.length == 1
        board[coords.first] = [turn]
        pool[turn] -= 1
      else
        if board[coords.first].length == 1
          board[coords.last] = board[coords[1]] + board[coords.last]
        else
          board[coords.last] = board[coords.first] + board[coords.last]
        end
        board[coords.last].flatten!
        board[coords.first] = board[coords[1]] = nil
        pool[turn] += 1
      end
      rotate_turn
      self
    end

    def final?
      has_moves.empty?
    end

    def score( player )
      count = 0
      board.pieces.each do |p|
        cs = board.occupied( p )

        next if cs.nil?
        count += cs.length if p.first == player && p.length == 3
      end
      count
    end

    private

    def initial_pool( length )
      ((length * 2 - 1) ** 2 - length * (length - 1) - 1) / 2
    end

    def required_triples( length )
      ((length - 3) * 2 + 1)
    end

    def center( length )
      Coord[length-1,length-1]
    end

    def capture_moves
      all = []
      board.pieces.each do |p|
        if p && p.first == opponent( turn )

          board.occupied( p ).each do |c|
            # Collect all possible attacking pieces
            attackers = []
            board.directions.each do |d|
              nc = c
              while nc = board.coords.next( nc, d )
                if board[nc] && board[nc].first == turn
                  attackers << [ nc, board[nc].length ]
                  break
                end
              end
            end

            # Construct all possible moves
            attackers.each do |a1|
              attackers.each do |a2|
                if a1 != a2 && a1.last + a2.last + board[c].length <= 4
                  all << "#{a1.first}#{a2.first}#{c}"
                end
              end
            end
          end

        end
      end

      all
    end

  end
end

