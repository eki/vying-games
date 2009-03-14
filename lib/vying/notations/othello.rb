
module Vying
  class OthelloNotation < Notation

    def self.notation_name
      :othello_notation
    end

    def to_move( s )
      s.to_s.downcase
    end

    def translate( move, player )
      if Coord[move]
        player == game.player_names.first ? move.to_s.upcase : move
      else
        move
      end
    end

  end
end

