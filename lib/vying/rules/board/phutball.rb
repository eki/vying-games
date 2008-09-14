# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

Rules.create( "Phutball" ) do
  name    "Phutball"
  version "1.0.0"

  players :ohs, :eks

  cache :init, :moves

  position do
    attr_reader :board, :jumping

    def init
      @board = Board.rect( 15, 21 )
      @board[:h11] = :white
      @jumping = false
    end

    def moves
      return []                       if final?
      return jumping_moves + ["pass"] if jumping

      placement_moves + jumping_moves
    end

    def apply!( move )
      if move.to_s == "pass"
        @jumping = false
        rotate_turn
        return self
      end

      coords = move.to_coords

      if coords.length == 1
        board[coords.first] = :black
        rotate_turn
      else
        coords = Coord.expand( coords )
        board.move( coords.first, coords.last )
        board[* coords[1,coords.length-2]] = nil

        if jumping_moves.empty?
          @jumping = false
          rotate_turn
        else
          @jumping = true
        end
      end

      self
    end

    def final?
      c = board.occupied( :white ).first
      c.y == 0 || c.y == 20 || (!jumping && (c.y == 1 || c.y == 19))
    end

    def winner?( player )
      c = board.occupied( :white ).first
      (player == :ohs && (c.y == 1 || c.y == 0)) ||
      (player == :eks && (c.y == 19 || c.y == 20))
    end

    def loser?( player )
      winner?( opponent( player ) )
    end

    def hash
      [board,turn].hash
    end

    def jumping_moves
      sc = board.occupied( :white ).first
      jmoves = []

      board.directions.each do |d|
        c = board.coords.next( sc, d )

        next if board[c].nil?

        ec = nil
        while c = board.coords.next( c, d )
          ec = c 
          break if board[c].nil?
        end
        jmoves << "#{sc}#{ec}" if ec && board[ec].nil?
      end

      jmoves
    end

    def placement_moves
      board.unoccupied - board.coords.row( :a1 ) - board.coords.row( :a21 )
    end
  end

end

