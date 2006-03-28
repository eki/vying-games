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

  class Position < Struct.new( :board, :turn, :lastc, :lastp )
    def to_s
      "Board:\n#{board}\nTurn: #{turn}\nLast: (#{lastc}, #{lastp})"
    end
  end

  def ConnectFour.init
    Position.new( ConnectFourBoard.new( 7, 6 ), 
              PlayerSet.new( *players ), nil, :noone )
  end

  def ConnectFour.players
    [Piece.red,Piece.blue]
  end

  def ConnectFour.ops( position )
    return nil if final?( position )

    a = []

    position.board.coords.width.times do |x|
      next unless position.board.drop?( x ) 

      p = position.turn

      op = Op.new( "Drop", "#{p.short}#{x}" ) do
        s = position.dup
        s.lastc, s.lastp = s.board.drop( x, s.turn.current ), s.turn.current
        s.turn.next!
        s
      end
      op.freeze
      a << op
    end

    (a == []) ? nil : a
  end

  def ConnectFour.final?( position )
    return false if position.lastc.nil?

    empties = position.board.count( nil )

    return true  if empties == 0
    return false if empties >  7*6-4

    b = position.board
    lc = position.lastc
    lp = position.lastp

    b.each_from( lc, [:e,:w] ) { |p| p == lp } >= 3 ||
    b.each_from( lc, [:n,:s] ) { |p| p == lp } >= 3 ||
    b.each_from( lc, [:ne,:sw] ) { |p| p == lp } >= 3 ||
    b.each_from( lc, [:nw,:se] ) { |p| p == lp } >= 3
  end

  def ConnectFour.winner?( position, player )
    b = position.board
    lc = position.lastc
    lp = position.lastp

    b.each_from( lc, [:e,:w] ) { |p| p == player } >= 3 ||
    b.each_from( lc, [:n,:s] ) { |p| p == player } >= 3 ||
    b.each_from( lc, [:ne,:sw] ) { |p| p == player } >= 3 ||
    b.each_from( lc, [:nw,:se] ) { |p| p == player } >= 3
  end

  def ConnectFour.loser?( position, player )
    !draw?( position ) && player != position.lastp
  end

  def ConnectFour.draw?( position )
    b = position.board
    lc = position.lastc
    lp = position.lastp

    b.count( nil ) == 0 &&
    b.each_from( lc, [:e,:w] ) { |p| p == lp } < 3 &&
    b.each_from( lc, [:n,:s] ) { |p| p == lp } < 3 &&
    b.each_from( lc, [:ne,:sw] ) { |p| p == lp } < 3 &&
    b.each_from( lc, [:nw,:se] ) { |p| p == lp } < 3
  end
end

