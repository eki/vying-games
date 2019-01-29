# frozen_string_literal: true

module Vying
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
           'F' => 'a1' }.freeze

    def to_move(s)
      TO[s] || s
    end

    FROM = [%w(F E D C B A),
             %w(a b c d e f)].freeze

    def translate(move, _player)
      Coord[move] ? FROM[move.y][move.x] : move
    end

  end
end
