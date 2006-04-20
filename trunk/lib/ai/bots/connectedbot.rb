require 'game'

class ConnectedBot < Bot
  def initialize( game, player )
    super( game, player )
  end

  def select
    ops = game.ops
    scores = ops.map do |op| 
      pos = game.rules.apply( game.history.last, op )
      opps = game.players.select { |p| p != player }

      b = pos.board

      b.coords.inject( 0 ) do |s,c|
        b[c] == player ? s + connected( b, c, player ) : s
      end
    end

    all = scores.zip( ops ).sort
    all.sort.last[1]
  end

  def connected( b, c, p )
    b[b.coords.neighbors( c )].inject( 0 ) do |s,piece| 
      r = s+2 if piece == p
      r = s   if piece.nil?
      r = s+1 if piece != nil && piece != p
      r
    end
  end
end

