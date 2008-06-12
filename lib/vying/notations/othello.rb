
class OthelloNotation < Notation

  def self.name
    :othello_notation
  end

  def to_move( s, player )
    s.to_s.downcase
  end

  def translate( move, player )
    player == game.player_names.first ? move.to_s.upcase : move
  end

end

