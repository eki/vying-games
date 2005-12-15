$:.unshift File.join( File.dirname( __FILE__ ), "..", "lib" )

require 'board'
require 'game'

class ConnectFourBoard < Board
  def drop?( x )
    self[x,0].empty?
  end

  def drop( x, piece )
    (height-1).downto( 0 ) do |y|
      if self[x,y].empty?
        self[x,y] = piece; break
      end
    end
  end
end

class ConnectFour

  def ConnectFour.init                               #Trickiness--Piece can
    { "board" => ConnectFourBoard.new( 7, 6 ),       #be used in place of
      "turn"  => PlayerSet.new( *players ) }         #Player--though not
  end                                                #vice versa

  def ConnectFour.players
    [Piece.red,Piece.blue]
  end

  def ConnectFour.ops( game )
    return nil if game.final? # Do we still want to check this here?

    a = []

    game.board.width.times do |x|
      next unless game.board.drop?( x ) 

      p = game.turn

      op = Op.new( "Drop", "#{p.short}#{x}" ) do
        s = game.history.last.dup
        s.board.drop( x, s.turn.current )
        s.turn.next!
        s
      end
      op.freeze
      a << op
    end

    (a == []) ? nil : a
  end

  def ConnectFour.final?( game )
    empties = game.board.count( Piece.empty )

    return true  if empties == 0
    return false if empties >  7*6-4

    return game.board               =~ /(\S)\1\1\1/ ||
           game.board.rotate( 45 )  =~ /(\S)\1\1\1/ ||
           game.board.rotate( 90 )  =~ /(\S)\1\1\1/ ||
           game.board.rotate( 315 ) =~ /(\S)\1\1\1/
  end

  def ConnectFour.winner?( game, player )
    return game.board               =~ /(#{player.short})\1\1\1/ ||
           game.board.rotate( 45 )  =~ /(#{player.short})\1\1\1/ ||
           game.board.rotate( 90 )  =~ /(#{player.short})\1\1\1/ ||
           game.board.rotate( 315 ) =~ /(#{player.short})\1\1\1/
  end

  def ConnectFour.loser?( game, player )
    return !draw?( game ) &&
           game.board               !~ /(#{player.short})\1\1\1/ &&
           game.board.rotate( 45 )  !~ /(#{player.short})\1\1\1/ &&
           game.board.rotate( 90 )  !~ /(#{player.short})\1\1\1/ &&
           game.board.rotate( 315 ) !~ /(#{player.short})\1\1\1/
  end

  def ConnectFour.draw?( game )
    return game.board               !~ /(\S)\1\1\1/ &&
           game.board.rotate( 45 )  !~ /(\S)\1\1\1/ &&
           game.board.rotate( 90 )  !~ /(\S)\1\1\1/ &&
           game.board.rotate( 315 ) !~ /(\S)\1\1\1/
  end

  def ConnectFour.score( game, player )
    return  0 if draw?( game )
    return  1 if winner?( game, player )
    return -1 if loser?( game, player )
  end

  def ConnectFour.to_s( game )
    "Board:\n#{game.board}\nTurn: #{game.turn}"
  end

end

