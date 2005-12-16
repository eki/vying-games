
require 'game'

class RandomBot

  def RandomBot.select( game )
    ops = game.ops
    ops[rand(ops.size)]
  end

end

