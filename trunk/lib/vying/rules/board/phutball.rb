require 'vying/rules'
require 'vying/board/board'

class Phutball < Rules

  info :name      => 'Phutball',
       :resources => ['Wikipedia <http://en.wikipedia.org/wiki/Phutball>']

  attr_reader :board, :jumping, :unused_ops

  players [:ohs, :eks]

  @@init_ops = Coords.new( 15, 21 ).select { |c| c.y != 0 && c.y != 20 }
  @@init_ops.map! { |c| c.to_s }
  @@init_ops.delete( "h11" )

  def initialize( seed=nil )
    super

    @board = Board.new( 15, 21 )
    @board[:h11] = :white

    @unused_ops = @@init_ops.dup
    @jumping = false
  end

  def op?( op, player=nil )
    return false unless player.nil? || has_ops.include?( player )
    !final? && ops.include?( op.to_s )
  end

  def ops( player=nil )
    return false unless player.nil? || has_ops.include?( player )
    return false if final?

    return jumping_ops + ["pass"] if jumping

    unused_ops + jumping_ops
  end

  def apply!( op )
    if op.to_s == "pass"
      @jumping = false
      turn( :rotate )
      return self
    end

    coords = op.to_s.scan( /[A-Za-z]+\d+/ )

    if coords.length == 1
      board[coords.first] = :black
      @unused_ops.delete( coords.first )
      turn( :rotate )
    else
      sc = coords.shift
      @unused_ops << sc

      sc = Coord[sc]
      board[sc] = nil

      while ec = coords.shift
        ec, c = Coord[ec], sc
        d = sc.direction_to ec
        while (c = board.coords.next( c, d )) != ec
          board[c] = nil
          @unused_ops << c
        end
        sc = ec
      end

      board[sc] = :white
      @unused_ops.delete( sc.to_s )

      if jumping_ops.empty?
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

  def draw?
    false
  end

  def hash
    [board,turn].hash
  end

  def jumping_ops
    sc = board.occupied[:white].first
    jops = []

    [:n,:s,:w,:e,:ne,:nw,:se,:sw].each do |d|
      c = board.coords.next( sc, d )

      next if board[c].nil?

      ec = nil
      while c = board.coords.next( c, d )
        ec = c 
        break if board[c].nil?
      end
      jops << "#{sc}#{ec}" if ec && board[ec].nil?
    end

    jops
  end
end

