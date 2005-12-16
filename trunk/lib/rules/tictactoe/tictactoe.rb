
require 'board'
require 'game'

class TicTacToe

  State = Struct.new( :board, :turn )

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

  def TicTacToe.score( state, player )
    return  0 if draw?( state )
    return  1 if winner?( state, player )
    return -1 if loser?( state, player )
  end

  def TicTacToe.to_s( state )
    "Board:\n#{state.board}\nTurn: #{state.turn}"
  end

end

