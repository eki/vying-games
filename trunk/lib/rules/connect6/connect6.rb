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

  class Position < Struct.new( :board, :turn, :lastc, :lastp )
    def to_s
      "Board:\n#{board}\nTurn: #{turn}\nLast: (#{lastc}, #{lastp})"
    end
  end

  def Connect6.init
    s = [Piece.black, Piece.white, Piece.white, Piece.black]
    Position.new( Board.new( 19, 19 ), PlayerSet.new( *s ), nil, :noone )
  end

  def Connect6.players
    [Piece.black,Piece.white]
  end

  def Connect6.ops( position )
    return nil if final?( position )

    a = []

    position.board.coords.each do |c|
      next unless position.board[c].nil?

      p = position.turn

      op = Op.new( "Place #{p.name}", c.to_s ) do
        s = position.dup
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

  def Connect6.final?( position )
    return false if position.lastc.nil?

    empties = position.board.count( nil )

    return true  if empties == 0
    return false if empties > 19*19-11

    b = position.board
    lc = position.lastc
    lp = position.lastp

    b.each_from( lc, [:e,:w] ) { |p| p == lp } >= 5 ||
    b.each_from( lc, [:n,:s] ) { |p| p == lp } >= 5 ||
    b.each_from( lc, [:ne,:sw] ) { |p| p == lp } >= 5 ||
    b.each_from( lc, [:nw,:se] ) { |p| p == lp } >= 5
  end

  def Connect6.winner?( position, player )
    b = position.board
    lc = position.lastc
    lp = position.lastp

    b.each_from( lc, [:e,:w] ) { |p| p == player } >= 5 ||
    b.each_from( lc, [:n,:s] ) { |p| p == player } >= 5 ||
    b.each_from( lc, [:ne,:sw] ) { |p| p == player } >= 5 ||
    b.each_from( lc, [:nw,:se] ) { |p| p == player } >= 5
  end

  def Connect6.loser?( position, player )
    !draw?( position ) && player != position.lastp
  end

  def Connect6.draw?( position )
    b = position.board
    lc = position.lastc
    lp = position.lastp

    b.count( nil ) == 0 &&
    b.each_from( lc, [:e,:w] ) { |p| p == lp } < 5 &&
    b.each_from( lc, [:n,:s] ) { |p| p == lp } < 5 &&
    b.each_from( lc, [:ne,:sw] ) { |p| p == lp } < 5 &&
    b.each_from( lc, [:nw,:se] ) { |p| p == lp } < 5
  end
end

