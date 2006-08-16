require 'game'

class RandomBot < Bot
  def select( position, player )
    ops = position.ops
    ops[rand(ops.size)]
  end
end

