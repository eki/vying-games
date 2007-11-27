# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying/ai/bot'
require 'vying/ai/search'

class RandomBot < Bot
  def select( sequence, position, player )
    moves = position.moves
    moves[rand(moves.size)]
  end
end

