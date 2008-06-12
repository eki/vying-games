
class OthelloNotation < Notation

  def self.name
    :othello_notation
  end

  def to_move( s, player=nil )
    s.to_s.downcase
  end

  def translate( move, player=nil )
    player == :black ? move.to_s.upcase : move
  end

end

