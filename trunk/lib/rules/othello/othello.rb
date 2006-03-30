# NAME
#   Othello
#

require 'board/standard'
require 'game'

class OthelloBoard < Board
  def valid?( c, bp, directions=[:n,:s,:e,:w,:ne,:nw,:se,:sw] )
    return false if !self[c].nil?

    op = bp == Piece.black ? Piece.white : Piece.black

    directions.each do |d|
      opc, f = 0, false
      each_from( c, [d] ) do |p| 
        p == op ? opc += 1 : (p == bp && opc > 0 ? f = true : nil)
      end
      return true if f 
    end

    false
  end

  def place( c, bp )
    op = bp == Piece.black ? Piece.white : Piece.black

    [:n,:s,:w,:e,:ne,:nw,:se,:sw].each do |d|
      if valid?( c, bp, [d] )
        tc = c
        while tc = coords.next( tc, d )
          self[tc] == op ? self[tc] = bp : break
        end
      end
    end
    self[c] = bp
  end
end

class Othello < Rules

  INFO = Info.new( __FILE__ )

  class Position < Struct.new( :board, :turn )
    def to_s
      "Board:\n#{board}\nTurn: #{turn}"
    end
  end

  def Othello.init
    b = OthelloBoard.new( 8, 8 )
    b[3,3] = b[4,4] = Piece.white
    b[3,4] = b[4,3] = Piece.black
    Position.new( b, PlayerSet.new( *players ) )
  end

  def Othello.players
    [Piece.black,Piece.white]
  end

  def Othello.op?( position, op )
    position.board.valid?( Coord.from_s( op.to_s ), position.turn )
  end

  def Othello.ops( position )
    b, bp = position.board, position.turn.current
    cs = b.coords.select { |c| b.valid?( c, bp ) }
    a = cs.map { |c| c.to_s }
    a == [] ? nil : a
  end

  def Othello.apply( position, op )
    pos = position.dup
    b, c = pos.board, Coord.from_s( op )
    b.place( c, pos.turn.current )
    pos.turn.next!
    return pos if ops( pos )
    pos.turn.next!
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

