require 'vying/board/board'

class MancalaBoard < Board
  def initialize( houses, ranks, seeds )
    super( houses, ranks )

    coords.each { |c| self[c] = seeds }
  end

end

