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

require 'board/standard'
require 'game'

class TicTacToe < Rules

  INFO = Info.new( __FILE__ )

  class Position < Struct.new( :board, :turn, :lastc, :lastp )
    def to_s
      "Board:\n#{board}\nTurn: #{turn}\nLast: #{last}"
    end
  end

  def TicTacToe.init
    Position.new( Board.new( 3, 3 ), PlayerSet.new( *players ), nil, :noone )
  end

  def TicTacToe.players
    [Piece.x,Piece.o]
  end
                                                    
  def TicTacToe.ops( position )
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

  def TicTacToe.final?( position )
    b = position.board
    lc = position.lastc
    lp = position.lastp

    return false if lc.nil?

    return true  if b.count( nil ) == 0
    return true  if b[b.coords.row( lc )].all? { |p| p == lp }
    return true  if b[b.coords.column( lc )].all? { |p| p == lp }

    dc1 = b.coords.diagonal( lc, 1 )
    return true  if dc1.length == 3 && b[dc1].all? { |p| p == lp }

    dc2 = b.coords.diagonal( lc, -1 )
    return true  if dc2.length == 3 && b[dc2].all? { |p| p == lp }

    return false
  end

  def TicTacToe.winner?( position, player )
    TicTacToe.final?( position ) && !TicTacToe.draw?( position ) &&
    position.lastp == player
  end

  def TicTacToe.loser?( position, player )
    TicTacToe.final?( position ) && !TicTacToe.draw?( position ) &&
    position.lastp != player
  end

  def TicTacToe.draw?( position )
    b = position.board
    lc = position.lastc
    lp = position.lastp

    return false if lc.nil?

    return false if b.count( nil ) != 0

    return false if b[b.coords.row( lc )].all? { |p| p == lp }
    return false if b[b.coords.column( lc )].all? { |p| p == lp }

    dc1 = b.coords.diagonal( lc, 1 )
    return false if dc1.length == 3 && b[dc1].all? { |p| p == lp }

    dc2 = b.coords.diagonal( lc, -1 )
    return false if dc2.length == 3 && b[dc2].all? { |p| p == lp }

    return true
  end
end

