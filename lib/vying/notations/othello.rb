
class OthelloNotation < Notation

  def self.notation_name
    :othello_notation
  end

  def to_move( s, player )
    s.to_s.downcase
  end

  def translate( move )
    if move =~ /\w\d+/
      player == game.player_names.first ? move.to_s.upcase : move
    else
      move
    end
  end

end

