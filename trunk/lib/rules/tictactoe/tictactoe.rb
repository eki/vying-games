# NAME
#   Tic Tac Toe
#
# ALIASES
#   Noughts and Crosses, Noughts and Crosses, X's and O's, Tick Tat Toe,
#   Tit Tat Toe
#
# RESOURCES
#   Wikipedia <http://en.wikipedia.org/wiki/Tic-tac-toe>
#

require 'board'
require 'game'

class TicTacToe < Rules

  INFO = Info.new( __FILE__ )

  class State < Struct.new( :board, :turn )
    def to_s
      "Board:\n#{board}\nTurn: #{turn}"
    end
  end

  def TicTacToe.init
    State.new( Board.new( 3, 3 ), PlayerSet.new( *players ) )
  end

  def TicTacToe.players
    [Piece.x,Piece.o]
  end
                                                    
  def TicTacToe.ops( state )
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

  def TicTacToe.final?( state )
    empties = state.board.count( Piece.empty )

    return true  if empties == 0
    return false if empties >  4

    state.board               =~ /(\S)\1\1/ ||
    state.board.rotate( 45 )  =~ /(\S)\1\1/ ||
    state.board.rotate( 90 )  =~ /(\S)\1\1/ ||
    state.board.rotate( 315 ) =~ /(\S)\1\1/
  end

  def TicTacToe.winner?( state, player )
    return state.board               =~ /(#{player.short})\1\1/ ||
           state.board.rotate( 45 )  =~ /(#{player.short})\1\1/ ||
           state.board.rotate( 90 )  =~ /(#{player.short})\1\1/ ||
           state.board.rotate( 315 ) =~ /(#{player.short})\1\1/
  end

  def TicTacToe.loser?( state, player )
    return !draw?( state) &&
           state.board               !~ /(#{player.short})\1\1/ &&
           state.board.rotate( 45 )  !~ /(#{player.short})\1\1/ &&
           state.board.rotate( 90 )  !~ /(#{player.short})\1\1/ &&
           state.board.rotate( 315 ) !~ /(#{player.short})\1\1/
  end

  def TicTacToe.draw?( state )
    return state.board               !~ /(\S)\1\1/ &&
           state.board.rotate( 45 )  !~ /(\S)\1\1/ &&
           state.board.rotate( 90 )  !~ /(\S)\1\1/ &&
           state.board.rotate( 315 ) !~ /(\S)\1\1/
  end
end

