$:.unshift File.join( File.dirname( __FILE__ ), "..", "lib" )

require 'board'
require 'game'

class TicTacToe

  def TicTacToe.init                                 #Trickiness--Piece can
    { "board" => Board.new( 3, 3 ),                  #be used in place of
      "turn"  => PlayerSet.new( *players ) }         #Player--though not 
  end                                                #vice versa

  def TicTacToe.players
    [Piece.x,Piece.o]
  end
                                                    
  def TicTacToe.ops( game )
    return nil if game.final? # Do we still want to check this here?

    a = []

    game.board.coords.each do |x,y|
      next unless game.board[x,y].empty?

      p = game.turn

      op = Op.new( "Place #{p.name}", Board.xy_to_s( x, y ) ) do
        s = game.history.last.dup
        s.board[x,y] = p.current
        s.turn.next!
        s
      end
      op.freeze
      a << op
    end

    (a == []) ? nil : a
  end

  def TicTacToe.final?( game )
    empties = game.board.count( Piece.empty )

    return true  if empties == 0
    return false if empties >  4

    game.board               =~ /(\S)\1\1/ ||
    game.board.rotate( 45 )  =~ /(\S)\1\1/ ||
    game.board.rotate( 90 )  =~ /(\S)\1\1/ ||
    game.board.rotate( 315 ) =~ /(\S)\1\1/
  end

  def TicTacToe.winner?( game, player )
    return game.board               =~ /(#{player.short})\1\1/ ||
           game.board.rotate( 45 )  =~ /(#{player.short})\1\1/ ||
           game.board.rotate( 90 )  =~ /(#{player.short})\1\1/ ||
           game.board.rotate( 315 ) =~ /(#{player.short})\1\1/
  end

  def TicTacToe.loser?( game, player )
    return !draw?( game ) &&
           game.board               !~ /(#{player.short})\1\1/ &&
           game.board.rotate( 45 )  !~ /(#{player.short})\1\1/ &&
           game.board.rotate( 90 )  !~ /(#{player.short})\1\1/ &&
           game.board.rotate( 315 ) !~ /(#{player.short})\1\1/
  end

  def TicTacToe.draw?( game )
    return game.board               !~ /(\S)\1\1/ &&
           game.board.rotate( 45 )  !~ /(\S)\1\1/ &&
           game.board.rotate( 90 )  !~ /(\S)\1\1/ &&
           game.board.rotate( 315 ) !~ /(\S)\1\1/
  end

  def TicTacToe.score( game, player )
    return  0 if draw?( game )
    return  1 if winner?( game, player )
    return -1 if loser?( game, player )
  end

  def TicTacToe.to_s( game )
    "Board:\n#{game.board}\nTurn: #{game.turn}"
  end

end

