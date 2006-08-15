require 'game'

class RandomBot < Bot
  def select( position )
    ops = position.ops
    ops[rand(ops.size)]
  end
end

