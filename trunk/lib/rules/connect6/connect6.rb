# NAME
#   Connect6
#
# RESOURCES
#   Wikipedia <http://en.wikipedia.org/wiki/Connect6>
#

require 'board'
require 'game'

class Connect6 < Rules

  INFO = Info.new( __FILE__ )

  class State < Struct.new( :board, :turn )
    def to_s
      "Board:\n#{board}\nTurn: #{turn}"
    end
  end

  def Connect6.init
    s = [Piece.black, Piece.white, Piece.white, Piece.black]
    State.new( Board.new( 19, 19 ), PlayerSet.new( *s ) )
  end

  def Connect6.players
    [Piece.black,Piece.white]
  end

  def Connect6.ops( state )
    return nil if final?( state )

    a = []

    state.board.coords.each do |x,y|
      next unless state.board[x,y].empty?

      p = state.turn

      op = Op.new( "Place #{p.name}", Board.xy_to_s( x, y ) ) do
        s = state.dup
        s.board[x,y] = p.current
        s.turn.next!
        s
      end
      op.freeze
      a << op
    end

    (a == []) ? nil : a
  end

  def Connect6.final?( state )
    empties = state.board.count( Piece.empty )

    return true  if empties == 0
    return false if empties > 19*19-11

    state.board               =~ /(\S)\1\1\1\1\1/ ||
    state.board.rotate( 45 )  =~ /(\S)\1\1\1\1\1/ ||
    state.board.rotate( 90 )  =~ /(\S)\1\1\1\1\1/ ||
    state.board.rotate( 315 ) =~ /(\S)\1\1\1\1\1/
  end

  def Connect6.winner?( state, player )
    return state.board               =~ /(#{player.short})\1\1\1\1\1/ ||
           state.board.rotate( 45 )  =~ /(#{player.short})\1\1\1\1\1/ ||
           state.board.rotate( 90 )  =~ /(#{player.short})\1\1\1\1\1/ ||
           state.board.rotate( 315 ) =~ /(#{player.short})\1\1\1\1\1/
  end

  def Connect6.loser?( state, player )
    return !draw?( state) &&
           state.board               !~ /(#{player.short})\1\1\1\1\1/ &&
           state.board.rotate( 45 )  !~ /(#{player.short})\1\1\1\1\1/ &&
           state.board.rotate( 90 )  !~ /(#{player.short})\1\1\1\1\1/ &&
           state.board.rotate( 315 ) !~ /(#{player.short})\1\1\1\1\1/
  end

  def Connect6.draw?( state )
    return state.board               !~ /(\S)\1\1\1\1\1/ &&
           state.board.rotate( 45 )  !~ /(\S)\1\1\1\1\1/ &&
           state.board.rotate( 90 )  !~ /(\S)\1\1\1\1\1/ &&
           state.board.rotate( 315 ) !~ /(\S)\1\1\1\1\1/
  end
end

