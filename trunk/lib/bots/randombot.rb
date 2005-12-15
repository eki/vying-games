$:.unshift File.join( File.dirname( __FILE__ ), "..", "lib" )

require 'game'

class RandomBot

  def RandomBot.select( game )
    ops = game.ops
    ops[rand(ops.size)]
  end

end

