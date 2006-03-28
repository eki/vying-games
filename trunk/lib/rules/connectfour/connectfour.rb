# NAME
#   Connect Four
#
# ALIASES
#   Plot Four, The Captain's Mistress
#

require 'board/standard'
require 'game'

class ConnectFourBoard < Board
  def drop?( x )
    self[x,0].nil?
  end

  def drop( x, piece )
    (coords.height-1).downto( 0 ) do |y|
      if self[x,y].nil?
        self[x,y] = piece; return Coord[x,y]
      end
    end
  end
end

class ConnectFour < Rules

  INFO = Info.new( __FILE__ )

  class State < Struct.new( :board, :turn, :lastc, :lastp )
    def to_s
      "Board:\n#{board}\nTurn: #{turn}\nLast: (#{lastc}, #{lastp})"
    end
  end

  def ConnectFour.init
    State.new( ConnectFourBoard.new( 7, 6 ), 
              PlayerSet.new( *players ), nil, :noone )
  end

  def ConnectFour.players
    [Piece.red,Piece.blue]
  end

  def ConnectFour.ops( state )
    return nil if final?( state )

    a = []

    state.board.coords.width.times do |x|
      next unless state.board.drop?( x ) 

      p = state.turn

      op = Op.new( "Drop", "#{p.short}#{x}" ) do
        s = state.dup
        s.lastc, s.lastp = s.board.drop( x, s.turn.current ), s.turn.current
        s.turn.next!
        s
      end
      op.freeze
      a << op
    end

    (a == []) ? nil : a
  end

  def ConnectFour.final?( state )
    return false if state.lastc.nil?

    empties = state.board.count( nil )

    return true  if empties == 0
    return false if empties >  7*6-4

    b = state.board
    lc = state.lastc
    lp = state.lastp

    b.to_s( b.coords.row( lc ) )          =~ /(#{lp.short})\1\1\1/ ||
    b.to_s( b.coords.column( lc ) )       =~ /(#{lp.short})\1\1\1/ ||
    b.to_s( b.coords.diagonal( lc, 1 ) )  =~ /(#{lp.short})\1\1\1/ ||
    b.to_s( b.coords.diagonal( lc, -1 ) ) =~ /(#{lp.short})\1\1\1/
  end

  def ConnectFour.winner?( state, player )
    b = state.board
    lc = state.lastc
    lp = state.lastp

    b.to_s( b.coords.row( lc ) )          =~ /(#{player.short})\1\1\1/ ||
    b.to_s( b.coords.column( lc ) )       =~ /(#{player.short})\1\1\1/ ||
    b.to_s( b.coords.diagonal( lc, 1 ) )  =~ /(#{player.short})\1\1\1/ ||
    b.to_s( b.coords.diagonal( lc, -1 ) ) =~ /(#{player.short})\1\1\1/
  end

  def ConnectFour.loser?( state, player )
    !draw?( state ) && player != state.lastp
  end

  def ConnectFour.draw?( state )
    b = state.board
    lc = state.lastc
    lp = state.lastp

    b.count( nil ) == 0 &&
    b.to_s( b.coords.row( lc ) )          !~ /(\S)\1\1\1/ &&
    b.to_s( b.coords.column( lc ) )       !~ /(\S)\1\1\1/ &&
    b.to_s( b.coords.diagonal( lc, 1 ) )  !~ /(\S)\1\1\1/ &&
    b.to_s( b.coords.diagonal( lc, -1 ) ) !~ /(\S)\1\1\1/
  end
end

