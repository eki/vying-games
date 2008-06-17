
class MancalaNotation < Notation

  def self.notation_name
    :mancala_notation
  end

  TO = { 'a' => 'a2',
         'b' => 'b2',
         'c' => 'c2',
         'd' => 'd2',
         'e' => 'e2',
         'f' => 'f2',

         'A' => 'f1',
         'B' => 'e1',
         'C' => 'd1',
         'D' => 'c1',
         'E' => 'b1',
         'F' => 'a1' }

  def to_move( s, player )
    TO[s]
  end

  FROM = [ ['F', 'E', 'D', 'C', 'B', 'A'],
           ['a', 'b', 'c', 'd', 'e', 'f'] ]

  def translate( move, player )
    FROM[move.y][move.x] || move
  end

end

