require 'game'

class RandomBot < Bot
  def initialize( game, player )
    super( game, player )
  end

  def select
    ops = game.ops
    ops[rand(ops.size)]
  end
end

