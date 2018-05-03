
# frozen_string_literal: true

module Vying
  class AbandeNotation < Notation

    def self.notation_name
      :abande_notation
    end

    def initialize(game)
      super(game)
      @board_size = game.board.length
    end

    def to_move(s)
      if s =~ /^\s*(\w\d)\s*$/
        conv(Regexp.last_match(1))
      elsif s =~ /^\s*(\w\d)-?(\w\d)\s*$/
        conv(Regexp.last_match(1)) + conv(Regexp.last_match(2))
      else
        s
      end
    end

    def translate(move, _player)
      cs = move.to_coords

      return move if cs.empty?

      s = ''
      cs.each do |c|
        if c.x >= @board_size
          s += (97 + c.x).chr + (c.y - (c.x - @board_size)).to_s
        else
          s += c.to_s
        end
      end
      s =~ /(\w\d)(\w\d)/ ? "#{Regexp.last_match(1)}-#{Regexp.last_match(2)}" : s
    end

    private

    def conv(c)
      if c.x >= @board_size
        (97 + c.x).chr + (c.y + (c.x - @board_size) + 2).to_s
      else
        c
      end
    end

  end
end
