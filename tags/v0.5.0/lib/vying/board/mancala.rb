# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying/board/board'

class MancalaBoard < Board
  def initialize( houses, ranks, seeds )
    super( houses, ranks )

    coords.each { |c| self[c] = seeds }
  end

end

