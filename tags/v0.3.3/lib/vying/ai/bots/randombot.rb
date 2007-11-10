require 'vying/ai/bot'
require 'vying/ai/search'

class RandomBot < AI::Bot
  def select( sequence, position, player )
    moves = position.moves
    moves[rand(moves.size)]
  end
end

