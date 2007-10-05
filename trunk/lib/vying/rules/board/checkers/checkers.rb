require 'vying/rules'
require 'vying/board/board'

class Checkers < Rules

  info :name      => 'Checkers',
       :resources => ['Wikipedia <http://en.wikipedia.org/wiki/Checkers>']

  allow_draws_by_agreement

  attr_reader :board, :jumping

  players [:red, :white]

  def initialize( seed=nil )
    super

    @board = Board.new( 8, 8 )
    @board[:b1,:d1,:f1,:h1,:a2,:c2,:e2,:g2,:b3,:d3,:f3,:h3] = :red
    @board[:a8,:c8,:e8,:g8,:b7,:d7,:f7,:h7,:a6,:c6,:e6,:g6] = :white

    @jumping = false
  end

  def move?( move, player=nil )
    return false unless player.nil? || has_moves.include?( player )
    tmp = moves || []
    tmp.include?( move.to_s )
  end

  def moves( player=nil )
    return false unless player.nil? || has_moves.include?( player )

    p    = turn
    opp  = (p    == :red) ? :white : :red
    k    = (p    == :red) ? :RED   : :WHITE
    oppk = (opp  == :red) ? :RED   : :WHITE

    jd  = (turn == :red) ? [:se, :sw] : [:ne, :nw]
    kjd = [:se, :sw, :ne, :nw]

    found = []

    if jumping
      c = jumping

      (board[c] == k ? kjd : jd).each do |d|
        p1 = board[c1 = board.coords.next( c, d )]
        p2 = board[c2 = board.coords.next( c1, d )] if c1
        if (p1 == opp || p1 == oppk) && p2.nil? && !c2.nil?
          found << "#{c}#{c2}"
        end
      end

      return found.empty? ? nil : found
    end

    board.occupied[p].each do |c|
      jd.each do |d|
        p1 = board[c1 = board.coords.next( c, d )]
        p2 = board[c2 = board.coords.next( c1, d )] if c1
        if (p1 == opp || p1 == oppk) && p2.nil? && !c2.nil?
          found << "#{c}#{c2}"
        end
      end
    end if board.occupied[p]

    board.occupied[k].each do |c|
      kjd.each do |d|
        p1 = board[c1 = board.coords.next( c, d )]
        p2 = board[c2 = board.coords.next( c1, d )] if c1
        if (p1 == opp || p1 == oppk) && p2.nil? && !c2.nil?
          found << "#{c}#{c2}"
        end
      end
    end if board.occupied[k]

    return found unless found.empty?

    board.occupied[p].each do |c|
      jd.each do |d|
        p1 = board[c1 = board.coords.next( c, d )]
        found << "#{c}#{c1}" if p1.nil? && ! c1.nil?
      end
    end if board.occupied[p]

    board.occupied[k].each do |c|
      kjd.each do |d|
        p1 = board[c1 = board.coords.next( c, d )]
        found << "#{c}#{c1}" if p1.nil? && ! c1.nil?
      end
    end if board.occupied[k]

    return found unless found.empty?

    false
  end

  def apply!( move )
    coords, p = Coord.expand( move.to_coords ), turn

    board.move( coords.first, coords.last )

    if coords.length == 3
      board[coords[1]] = nil
      @jumping = coords.last

      unless moves
        turn( :rotate )
        @jumping = false
      end
    else
      turn( :rotate )
    end

    if p == :red && coords.last.y == 7
      board[coords.last] = :RED
    elsif p == :white && coords.last.y == 0
      board[coords.last] = :WHITE
    end

    self
  end

  def final?
    ! moves
  end

  def winner?( player )
    player != turn
  end

  def loser?( player )
    player == turn
  end

  def draw?
    false
  end

  def hash
    [board,turn].hash
  end

end

