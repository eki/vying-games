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

  def ConnectFour.op?( position, op )
    op.to_s =~ /(r|b)(\d)/
    position.board.drop?( $2.to_i )
  end

  def ConnectFour.ops( position )
    return nil if final?( position )
    xs = (0..position.board.coords.width).select { |x| position.board.drop? x }
    a = xs.map { |x| "#{position.turn.short}#{x}" }
    a == [] ? nil : a
  end

  def ConnectFour.apply( position, op )
    op.to_s =~ /(r|b)(\d)/
    x, pos, p = $2.to_i, position.dup, position.turn.current
    pos.lastc, pos.lastp = pos.board.drop( x, p ), p
    pos.turn.next!
    pos
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

