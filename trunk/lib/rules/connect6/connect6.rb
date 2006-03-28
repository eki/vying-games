# NAME
#   Connect6
#
# RESOURCES
#   Wikipedia <http://en.wikipedia.org/wiki/Connect6>
#

require 'board/standard'
require 'game'

class Connect6 < Rules

  INFO = Info.new( __FILE__ )

  class State < Struct.new( :board, :turn, :lastc, :lastp )
    def to_s
      "Board:\n#{board}\nTurn: #{turn}\nLast: (#{lastc}, #{lastp})"
    end
  end

  def Connect6.init
    s = [Piece.black, Piece.white, Piece.white, Piece.black]
    State.new( Board.new( 19, 19 ), PlayerSet.new( *s ), nil, :noone )
  end

  def Connect6.players
    [Piece.black,Piece.white]
  end

  def Connect6.ops( state )
    return nil if final?( state )

    a = []

    state.board.coords.each do |c|
      next unless state.board[c].nil?

      p = state.turn

      op = Op.new( "Place #{p.name}", c.to_s ) do
        s = state.dup
        s.board[c] = p.current
        s.lastc, s.lastp = c, p.current
        s.turn.next!
        s
      end
      op.freeze
      a << op
    end

    (a == []) ? nil : a
  end

  def Connect6.final?( state )
    return false if state.lastc.nil?

    empties = state.board.count( nil )

    return true  if empties == 0
    return false if empties > 19*19-11

    b = state.board
    lc = state.lastc
    lp = state.lastp

    b.to_s( b.coords.row( lc ) )          =~ /(#{lp.short})\1\1\1\1\1/ ||
    b.to_s( b.coords.column( lc ) )       =~ /(#{lp.short})\1\1\1\1\1/ ||
    b.to_s( b.coords.diagonal( lc, 1 ) )  =~ /(#{lp.short})\1\1\1\1\1/ ||
    b.to_s( b.coords.diagonal( lc, -1 ) ) =~ /(#{lp.short})\1\1\1\1\1/
  end

  def Connect6.winner?( state, player )
    b = state.board
    lc = state.lastc
    lp = state.lastp

    b.to_s( b.coords.row( lc ) )          =~ /(#{player.short})\1\1\1\1\1/ ||
    b.to_s( b.coords.column( lc ) )       =~ /(#{player.short})\1\1\1\1\1/ ||
    b.to_s( b.coords.diagonal( lc, 1 ) )  =~ /(#{player.short})\1\1\1\1\1/ ||
    b.to_s( b.coords.diagonal( lc, -1 ) ) =~ /(#{player.short})\1\1\1\1\1/
  end

  def Connect6.loser?( state, player )
    !draw?( state ) && player != state.lastp
  end

  def Connect6.draw?( state )
    b = state.board
    lc = state.lastc
    lp = state.lastp

    b.count( nil ) == 0 &&
    b.to_s( b.coords.row( lc ) )          !~ /(\S)\1\1\1\1\1/ &&
    b.to_s( b.coords.column( lc ) )       !~ /(\S)\1\1\1\1\1/ &&
    b.to_s( b.coords.diagonal( lc, 1 ) )  !~ /(\S)\1\1\1\1\1/ &&
    b.to_s( b.coords.diagonal( lc, -1 ) ) !~ /(\S)\1\1\1\1\1/
  end
end

