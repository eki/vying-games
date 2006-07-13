# NAME
#   Othello
#

require 'board/standard'
require 'game'

class OthelloBoard < Board
  def valid?( c, bp, directions=[:n,:s,:e,:w,:ne,:nw,:se,:sw] )
    return false if !self[c].nil?

    op = bp == Piece.black ? Piece.white : Piece.black

    a = directions.zip( coords.neighbors_nil( c, directions ) )
    a.each do |d,nc|
      p = self[nc]
      next if p.nil? || p == bp

      i = nc
      while (i = coords.next( i, d ))
        p = self[i]
        return true if p == bp 
        break       if p.nil?
      end
    end

    false
  end

  def place( c, bp )
    op = bp == Piece.black ? Piece.white : Piece.black

    directions = [:n,:s,:w,:e,:ne,:nw,:se,:sw]

    a = directions.zip( coords.neighbors_nil( c, directions ) )
    a.each do |d,nc|
      p = self[nc]
      next if p.nil? || p == bp

      bt = [nc]
      while (bt << coords.next( bt.last, d ))
        p = self[bt.last]
        break if p.nil?

        if p == bp
          bt.each { |bc| self[bc] = bp }
          break
        end
      end
    end

    self[c] = bp
  end
end

class Othello < Rules

  INFO = info( __FILE__ )

  class Position < Struct.new( :board, :turn, :occupied, :frontier, :ops_cache )
    def to_s
      "Board:\n#{board}\nTurn: #{turn}"
    end
  end

  def Othello.frontier( coords )
  end

  def Othello.init( seed=nil )
    b = OthelloBoard.new( 8, 8 )
    b[3,3] = b[4,4] = Piece.white
    b[3,4] = b[4,3] = Piece.black

    occupied = [Coord[3,3], Coord[4,4], Coord[3,4], Coord[4,3]]
    frontier = occupied.map { |c| b.coords.neighbors( c ) }
    frontier = frontier.flatten.select { |c| b[c].nil? }.uniq

    Position.new( b, PlayerSet.new( *players ), occupied, frontier, :ns )
  end

  def Othello.players
    [Piece.black,Piece.white]
  end

  def Othello.op?( position, op )
    position.board.valid?( Coord[op], position.turn )
  end

  def Othello.ops( position )
    return position.ops_cache if position.ops_cache != :ns
    b, bp, f = position.board, position.turn.current, position.frontier
    a = f.select { |c| b.valid?( c, bp ) }.map { |c| c.to_s }
    position.ops_cache = (a == [] ? nil : a)
  end

  def Othello.apply( position, op )
    pos = position.dup
    b, c = pos.board, Coord[op]
    b.place( c, pos.turn.current )

    pos.occupied << c

    pos.frontier += b.coords.neighbors( c ).select { |nc| b[nc].nil? }
    pos.frontier.uniq!
    pos.frontier.delete( c )

    pos.turn.next!
    pos.ops_cache = :ns
    return pos if ops( pos )

    pos.turn.next!
    pos.ops_cache = :ns
    pos
  end

  def Othello.final?( position )
    !ops( position )
  end

  def Othello.winner?( position, player )
    opp = player == Player.black ? Player.white : Player.black
    position.board.count( player ) > position.board.count( opp )
  end

  def Othello.loser?( position, player )
    opp = player == Player.black ? Player.white : Player.black
    position.board.count( player ) < position.board.count( opp )
  end

  def Othello.draw?( position )
    position.board.count( Player.white ) == position.board.count( Player.black )
  end
end

