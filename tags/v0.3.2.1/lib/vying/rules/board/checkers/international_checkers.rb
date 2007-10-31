require 'vying/rules'
require 'vying/board/board'

class InternationalCheckers < Rules

  info :name      => 'International Checkers',
       :resources => 
         ['Wikipedia <http://en.wikipedia.org/wiki/International_draghts>']

  attr_reader :board, :jumping

  players [:white, :red]

  def initialize( seed=nil )
    super

    @board = Board.new( 10, 10 )

    @board[:b1,:d1,:f1,:h1,:j1,
           :a2,:c2,:e2,:g2,:i2,
           :b3,:d3,:f3,:h3,:j3,
           :a4,:c4,:e4,:g4,:i4] = :red

    @board[:a10,:c10,:e10,:g10,:i10,
           :b9,:d9,:f9,:h9,:j9,
           :a8,:c8,:e8,:g8,:i8,
           :b7,:d7,:f7,:h7,:j7] = :white

    @jumping = false
  end

  def moves( player=nil )
    return [] unless player.nil? || has_moves.include?( player )

    p    = turn
    opp  = (p    == :red) ? :white : :red
    k    = (p    == :red) ? :RED   : :WHITE
    oppk = (opp  == :red) ? :RED   : :WHITE

    jd  = [:se, :sw, :ne, :nw]
    kjd = [:se, :sw, :ne, :nw]

    found = []

    if jumping
      c = jumping

      jd.each do |d|
        p1 = board[c1 = board.coords.next( c, d )]
        p2 = board[c2 = board.coords.next( c1, d )] if c1
        if (p1 == opp || p1 == oppk) && p2.nil? && !c2.nil?
          found << "#{c}#{c1}#{c2}"
        end
      end

      return found.empty? ? nil : found
    end

    board.occupied[p].each do |c|
      jd.each do |d|
        p1 = board[c1 = board.coords.next( c, d )]
        p2 = board[c2 = board.coords.next( c1, d )] if c1
        if (p1 == opp || p1 == oppk) && p2.nil? && !c2.nil?
          found << "#{c}#{c1}#{c2}"
        end
      end
    end if board.occupied[p]

    board.occupied[k].each do |c|
      kjd.each do |d|
        p1 = board[c1 = board.coords.next( c, d )]
        p2 = board[c2 = board.coords.next( c1, d )] if c1
        if (p1 == opp || p1 == oppk) && p2.nil? && !c2.nil?
          found << "#{c}#{c1}#{c2}"
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
    coords, p = move.to_coords, turn

    board.move( coords.first, coords.last )

    if coords.length == 3
      board[coords[1]] = nil
      @jumping = coords.last

      if moves.empty?
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
    moves.empty?
  end

  def winner?( player )
    player != turn
  end

  def loser?( player )
    player == turn
  end

  def hash
    [board,turn].hash
  end

end

