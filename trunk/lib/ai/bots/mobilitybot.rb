require 'game'

class MobilityBot < Bot
  def initialize( game, player )
    super( game, player )
  end

  def evaluate( position )
    score = game.rules.ops( position ).length
    position.turn.next!
    score - game.rules.ops( position ).length
  end
end

