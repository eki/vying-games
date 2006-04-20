require 'game'

class MobilityBot < Bot
  def initialize( game, player )
    super( game, player )
  end

  def select
    ops = game.ops
    scores = ops.map do |op| 
      pos = game.rules.apply( game.history.last, op )
      ops2 = game.rules.ops( pos )
      len = ops2.nil? ? 0 : ops2.length
      pos.turn.current != player ? ops.length - len : len
    end

    all = scores.zip( ops ).sort
    all.sort.last[1]
  end
end

