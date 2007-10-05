require 'vying/rules'
require 'vying/board/board'

class Makyek < Rules

  info :name      => 'Mak-yek',
       :resources => ['Wikipedia <http://en.wikipedia.org/wiki/Mak-yek>'],
       :aliases   => ['Makyek']

  attr_reader :board, :lastc, :moves_cache
  ignore :moves_cache

  players [:white, :black]

  def initialize( seed=nil )
    super

    @board = Board.new( 8, 8 )

    wrs = [Coord[0,0], Coord[1,0], Coord[2,0], Coord[3,0],
           Coord[4,0], Coord[5,0], Coord[6,0], Coord[7,0],
           Coord[0,2], Coord[1,2], Coord[2,2], Coord[3,2],
           Coord[4,2], Coord[5,2], Coord[6,2], Coord[7,2]]
    
    brs = [Coord[0,7], Coord[1,7], Coord[2,7], Coord[3,7],
           Coord[4,7], Coord[5,7], Coord[6,7], Coord[7,7],
           Coord[0,5], Coord[1,5], Coord[2,5], Coord[3,5],
           Coord[4,5], Coord[5,5], Coord[6,5], Coord[7,5]]
    
    wrs.each { |c| board[c] = :white }
    brs.each { |c| board[c] = :black }

    @lastc = nil
    @moves_cache = :ns
  end

  def move?( move, player=nil )
    return false unless player.nil? || has_moves.include?( player )
    return false unless move.to_s =~ /(\w\d+)(\w\d+)/

    sc = Coord[$1]
    ec = Coord[$2]

    rooks = board.occupied[turn]

    return false unless rooks.include?( sc )
    return false unless d = sc.direction_to( ec )
    return false unless [:n,:s,:e,:w].include?( d )

    ic = sc
    while (ic = board.coords.next( ic, d ))
      return false if !board[ic].nil?
      break        if ic == ec
    end

    return true
  end

  def moves( player=nil )
    return []          unless player.nil? || has_moves.include?( player )
    return []          if final?
    return moves_cache if moves_cache != :ns

    a = []

    rooks = board.occupied[turn]

    rooks.each do |c| 
      [:n,:e,:s,:w].each do |d|
        ic = c
        while (ic = board.coords.next( ic, d ))
          board[ic].nil? ? a << "#{c}#{ic}" : break;
        end
      end
    end

    @moves_cache = a
  end

  def apply!( move )
    coords = move.to_coords
    sc = coords.first
    ec = coords.last

    board.move( sc, ec )
    rooks = board.occupied[turn]
    rooks.delete( sc )
    rooks << ec

    opp = turn == :white ? :black : :white

    cap = []

    # Intervention capture
    if board.coords.neighbors_nil( ec, [:n,:s] ).all? { |c| board[c] == opp }
      cap << board.coords.next( ec, :n ) << board.coords.next( ec, :s )
    elsif board.coords.neighbors_nil( ec, [:e,:w] ).all? { |c| board[c] == opp }
      cap << board.coords.next( ec, :e ) << board.coords.next( ec, :w )
    end

    # Custodian capture
    directions = [:n,:s,:e,:w]
    a = directions.zip( board.coords.neighbors_nil( ec, directions ) )
    a.each do |d,nc|
      next if board[nc].nil? || board[nc] == board[ec]

      bt = [nc]
      while (bt << board.coords.next( bt.last, d ))
        break if board[bt.last].nil?

        if board[bt.last] == board[ec]
          bt.each { |bc| cap << bc if board[bc] != board[ec] }
        end
      end
    end

    opp_rooks = board.occupied[turn == :white ? :black : :white]
    cap.each { |c| board[c] = nil; opp_rooks.delete( c ) }

    turn( :rotate )
    @lastc = ec
    @moves_cache = :ns
    return self unless moves.empty?

    turn( :rotate )
    @moves_cache = :ns

    self
  end

  def final?
    board.count( :white ) < 5 || board.count( :black ) < 5
  #  wrs.empty? || brs.empty?   # does this get locked up?
  end

  def winner?( player )
    turn != player
  end

  def loser?( player )
    turn == player
  end

  def hash
    [board, turn].hash
  end
end

