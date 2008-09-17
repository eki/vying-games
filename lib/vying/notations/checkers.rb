
class CheckersNotation < Notation

  def self.notation_name
    :checkers_notation
  end

  def to_move( s )
    if s =~ /(\d+)-(\d+)/
      n1, n2 = $1.to_i, $2.to_i

      b = game.board

      i1, i2 = n1 * 2 - 1,             n2 * 2 - 1
      y1, y2 = i1 / b.width,           i2 / b.width
      x1, x2 = i1 % b.width - y1 % 2,  i2 % b.width - y2 % 2

      c1 = Coord[x1, y1]
      c2 = Coord[x2, y2]

      "#{c1}#{c2}"
    else
      s
    end
  end

  def translate( move, player )
    cs = move.to_coords

    if cs.length == 2
      c1, c2 = cs
      b = game.board

      n1 = (c1.x + c1.y * b.width) / 2 + 1
      n2 = (c2.x + c2.y * b.width) / 2 + 1

      "#{n1}-#{n2}"
    else
      move
    end
  end

end

