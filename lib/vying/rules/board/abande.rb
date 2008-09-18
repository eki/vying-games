# Copyright 2008, Eric Idema, Dieter Stein except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

# Abande
#
# For detailed rules see:  http://vying.org/games/abande
# or the official Abande site: http://abande.com

Rules.create( 'Abande' ) do
  name     'Abande'
  version  '0.2.0'
  notation :abande_notation

  players :black, :white
  option :board_size, :default => 4, :values => Array( 3..6 )

  score_determines_outcome

  cache :moves

  position do
    attr_reader :board, :pool, :pass

    def init
      length = @options[:board_size]

      @board = Board.hexagon( length, :plugins => [:stacking] )
      @pool  = Hash.new( @pool_size = initial_pool( length ) )
      @pass  = { :white => false, :black => false }
    end

    def has_moves
      return []      if pass[:white] && pass[:black]
      return [turn]  if pool[turn] > 0
      return [turn]  if capture_moves.any?

      []
    end

    def moves
      all = []
      all += pool[turn] > 0 ? placement_moves : [:pass]
      all += capture_moves
    end

    def apply!( move )
      if move == 'pass'
        pass[turn] = true
      else
        pass[turn] = pass[opponent( turn )] = false
        coords = move.to_coords
        if coords.length == 1
          board[coords.first] = [turn]
          pool[turn] -= 1
        else
          board[coords.last] = board[coords.first] + board[coords.last]
          board[coords.first] = nil
        end
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
        count += cs.length if p.first == player # TODO: && adjacent to opponent
      end
      count
    end

    private

    def initial_pool( length )
      ((length * 2 - 1) ** 2 - length * (length - 1) - 1) / 2
    end

    def placement_moves
      all = []
      if turn == :black && pool[:black] == @pool_size
        all += board.unoccupied
      else
        board.unoccupied.each do |c|
          nboard = board.dup
          nboard[c] = [turn]
          all << c if all_connected?( nboard.occupied )
        end
      end

      all
    end

    def capture_moves
      all = []
      unless turn == :black && pool[:black] == @pool_size-1
        board.pieces.each do |p|
          if p && p.first == turn
            board.occupied( p ).each do |c|
              board.coords.neighbors( c ).each do |n|
                if board[n] && board[n].first == opponent( turn ) && board[c].length + board[n].length <= 3
                  nboard = board.dup
                  nboard[n] = nboard[c] + nboard[n]
                  nboard[c] = nil
                  all << "#{c}#{n}" if all_connected?( nboard.occupied )
                end
              end
            end
          end
        end
      end

      all
    end

    def all_connected?( coords )
      check = [coords.first]

      while c = check.pop
        coords.delete c

        board.coords.neighbors( c ).each do |nc|
          check << nc if coords.include?( nc )
        end
      end

      coords.empty?
    end

  end
end

