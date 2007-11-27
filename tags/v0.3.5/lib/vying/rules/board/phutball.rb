# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying/rules'
require 'vying/board/board'

class Phutball < Rules

  info :name      => 'Phutball',
       :resources => ['Wikipedia <http://en.wikipedia.org/wiki/Phutball>']

  attr_reader :board, :jumping, :unused_moves

  players [:ohs, :eks]

  @@init_moves = Coords.new( 15, 21 ).select { |c| c.y != 0 && c.y != 20 }
  @@init_moves.map! { |c| c.to_s }
  @@init_moves.delete( "h11" )

  def initialize( seed=nil )
    super

    @board = Board.new( 15, 21 )
    @board[:h11] = :white

    @unused_moves = @@init_moves.dup
    @jumping = false
  end

  def moves( player=nil )
    return []    unless player.nil? || has_moves.include?( player )
    return []    if final?

    return jumping_moves + ["pass"] if jumping

    unused_moves + jumping_moves
  end

  def apply!( move )
    if move.to_s == "pass"
      @jumping = false
      turn( :rotate )
      return self
    end

    coords = move.to_coords

    if coords.length == 1
      board[coords.first] = :black
      @unused_moves.delete( coords.first.to_s )
      turn( :rotate )
    else
      sc = coords.shift
      @unused_moves << sc

      sc = Coord[sc]
      board[sc] = nil

      while ec = coords.shift
        ec, c = Coord[ec], sc
        d = sc.direction_to ec
        while (c = board.coords.next( c, d )) != ec
          board[c] = nil
          @unused_moves << c
        end
        sc = ec
      end

      board[sc] = :white
      @unused_moves.delete( sc.to_s )

      if jumping_moves.empty?
        @jumping = false
        turn( :rotate )
      else
        @jumping = true
      end
    end

    self
  end

  def final?
    c = board.occupied[:white].first
    c.y == 0 || c.y == 20 || (!jumping && (c.y == 1 || c.y == 19))
  end

  def winner?( player )
    c = board.occupied[:white].first
    (player == :ohs && (c.y == 1 || c.y == 0)) ||
    (player == :eks && (c.y == 19 || c.y == 20))
  end

  def loser?( player )
    c = board.occupied[:white].first
    (player == :ohs && (c.y == 19 || c.y == 20)) ||
    (player == :eks && (c.y == 1 || c.y == 0))
  end

  def hash
    [board,turn].hash
  end

  def jumping_moves
    sc = board.occupied[:white].first
    jmoves = []

    [:n,:s,:w,:e,:ne,:nw,:se,:sw].each do |d|
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
end

