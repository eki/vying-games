# NAME
#   Othello
#

require 'board'
require 'game'

class Othello < Rules

  INFO = Info.new( __FILE__ )

  BLACK = TwoSidedPiece.new( Piece.black, Piece.white )
  WHITE = TwoSidedPiece.new( Piece.white, Piece.black )

  class State < Struct.new( :board, :turn, :opscache, :frontier )
    def to_s
      "Board:\n#{board}\nTurn: #{turn}"
    end
  end

  def Othello.init
    b = Board.new( 8, 8, TwoSidedPiece )
    b[3,3] = b[4,4] = BLACK
    b[3,4] = b[4,3] = WHITE
    f = b.neighbors8( 3, 3 ) + b.neighbors8( 4, 4 ) +
        b.neighbors8( 3, 4 ) + b.neighbors8( 4, 3 )
    f.reject! { |x,y| !b[x,y].empty? }
    f.uniq!
    State.new( b, PlayerSet.new( *players ), nil, f )
  end

  def Othello.players
    [BLACK,WHITE]
  end
                                                    
  def Othello.ops( state )
    return state.opscache unless state.opscache.nil?

    a = []

    pass = Op.new( "Pass", "p" ) do
      s = state.dup
      s.turn.next!
      s.opscache = nil
      s
    end

    state.frontier.each do |x,y|
      next unless state.board[x,y].empty?
      next unless state.board.capture?( x, y, state.turn )

      op = Op.new( "Place #{state.turn.name}", Board.xy_to_s( x, y ) ) do
        s = state.dup
        s.board.capture( x, y, state.turn.current ) { |p| p.flip! }
        s.turn.next!
        s.opscache = nil
        s.frontier += s.board.neighbors8( x, y )
        s.frontier.reject! { |x,y| !s.board[x,y].empty? }
        s.frontier.uniq!
        s
      end
      op.freeze
      a << op
    end

    state.opscache = (a == []) ? [pass] : a
  end

  def Othello.final?( state )
    state.board.count( Piece.empty ) == 0 || ops( state ).nil?
  end

  def Othello.winner?( state, player )
    player = player == BLACK ? BLACK : WHITE
    state.board.count( player ) > state.board.count( player.flip )
  end

  def Othello.loser?( state, player )
    player = player == BLACK ? BLACK : WHITE
    state.board.count( player ) < state.board.count( player.flip )
  end

  def Othello.draw?( state )
    player = player == BLACK ? BLACK : WHITE
    state.board.count( player ) == state.board.count( player.flip )
  end
end

