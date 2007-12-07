# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying/ai/bot'
require 'vying/rules'

class RandomBot < Bot
  def RandomBot.select( sequence, position, player )
    moves = position.moves
    moves[rand(moves.size)]
  end

  Rules.list.each do |r|
    class_eval <<-EVAL
      class #{r} < Bot
        def select( sequence, position, player )
          RandomBot.select( sequence, position, player )
        end
      end
    EVAL
  end
end

