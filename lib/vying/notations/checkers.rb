
class CheckersNotation < Notation

  def self.notation_name
    :checkers_notation
  end

  def to_move( s, player )
    s =~ /(\d+)-(\d+)/
    n1, n2 = $1.to_i, $2.to_i

    b = game.board

    i1, i2 = (n1 - 1) * 2, (n2 - 1) * 2

    c1 = Coord[i1 % b.width, i1 / b.width]
    c2 = Coord[i2 % b.width, i2 / b.width]

    "#{c1}#{c2}"
  end

  def translate( move )
    if move =~ /\w\d+\w\d+/
      c1, c2 = move.to_coords
      b = game.board

      n1 = (c1.x + c1.y * b.width) / 2 + 1
      n2 = (c2.x + c2.y * b.width) / 2 + 1

      "#{n1}-#{n2}"
    else
      move
    end
  end

end

