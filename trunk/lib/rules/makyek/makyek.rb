require 'board/standard'
require 'game'

class Makyek < Rules

  info :name      => 'Mak-yek',
       :resources => ['Wikipedia <http://en.wikipedia.org/wiki/Mak-yek>'],
       :aliases   => ['Makyek']

  position :board, :turn, :lastc, :wrs, :brs, :ops_cache
  display  :board

  players [:white, :black]

  def Makyek.init( seed=nil )
    b = Board.new( 8, 8 )

    wrs = [Coord[0,0], Coord[1,0], Coord[2,0], Coord[3,0],
           Coord[4,0], Coord[5,0], Coord[6,0], Coord[7,0],
           Coord[0,2], Coord[1,2], Coord[2,2], Coord[3,2],
           Coord[4,2], Coord[5,2], Coord[6,2], Coord[7,2]]
    
    brs = [Coord[0,7], Coord[1,7], Coord[2,7], Coord[3,7],
           Coord[4,7], Coord[5,7], Coord[6,7], Coord[7,7],
           Coord[0,5], Coord[1,5], Coord[2,5], Coord[3,5],
           Coord[4,5], Coord[5,5], Coord[6,5], Coord[7,5]]
    
    wrs.each { |c| b[c] = :white }
    brs.each { |c| b[c] = :black }

    ps = players.dup

    Position.new( b, ps, nil, wrs, brs, :ns )
  end

  def Makyek.op?( position, op, player=nil )
    return false unless player.nil? || has_ops( position ).include?( player )
    return false unless op.to_s =~ /(\w\d+)(\w\d+)/

    sc = Coord[$1]
    ec = Coord[$2]

    rooks = position.turn.now == :white ? position.wrs : position.brs

    return false unless rooks.include?( sc )
    return false unless d = sc.direction_to( ec )
    return false unless [:n,:s,:e,:w].include?( d )

    ic = sc
    while (ic = position.board.coords.next( ic, d ))
      return false if !position.board[ic].nil?
      break        if ic == ec
    end

    return true
  end

  def Makyek.ops( position, player=nil )
    return false              unless player.nil? || 
                                     has_ops( position ).include?( player )
    return nil                if final?( position )
    return position.ops_cache if position.ops_cache != :ns

    a = []
    b = position.board

    rooks = position.turn.now == :white ? position.wrs : position.brs

    rooks.each do |c| 
      [:n,:e,:s,:w].each do |d|
        ic = c
        while (ic = b.coords.next( ic, d ))
          b[ic].nil? ? a << "#{c}#{ic}" : break;
        end
      end
    end

    position.ops_cache = a == [] ? nil : a
  end

  def Makyek.apply( position, op )
    op.to_s =~ /(\w\d+)(\w\d+)/
    sc = Coord[$1]
    ec = Coord[$2]

    pos = position.dup
    b = pos.board

    b.move( sc, ec )
    rooks = pos.turn.now == :white ? pos.wrs : pos.brs
    rooks.delete( sc )
    rooks << ec

    opp = pos.turn.now == :white ? :black : :white

    cap = []

    # Intervention capture
    if b.coords.neighbors_nil( ec, [:n,:s] ).all? { |c| b[c] == opp }
      cap << b.coords.next( ec, :n ) << b.coords.next( ec, :s )
    elsif b.coords.neighbors_nil( ec, [:e,:w] ).all? { |c| b[c] == opp }
      cap << b.coords.next( ec, :e ) << b.coords.next( ec, :w )
    end

    # Custodian capture
    directions = [:n,:s,:e,:w]
    a = directions.zip( b.coords.neighbors_nil( ec, directions ) )
    a.each do |d,nc|
      next if b[nc].nil? || b[nc] == b[ec]

      bt = [nc]
      while (bt << b.coords.next( bt.last, d ))
        break if b[bt.last].nil?

        if b[bt.last] == b[ec]
          bt.each { |bc| cap << bc if b[bc] != b[ec] }
        end
      end
    end

    opp_rooks = pos.turn.now == :white ? pos.brs : pos.wrs
    cap.each { |c| b[c] = nil; opp_rooks.delete( c ) }

    pos.turn.rotate!
    pos.lastc = ec
    pos.ops_cache = :ns
    return pos if ops( pos )

    pos.turn.rotate!
    pos.ops_cache = :ns
    pos
  end

  def Makyek.final?( position )
    position.wrs.length < 5 || position.brs.length < 5
  #  position.wrs.empty? || position.brs.empty?   # does this get locked up?
  end

  def Makyek.winner?( position, player )
    position.turn.now != player
  end

  def Makyek.loser?( position, player )
    position.turn.now == player
  end

  def Makyek.draw?( position )
    false
  end


end

