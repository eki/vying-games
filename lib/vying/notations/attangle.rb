# frozen_string_literal: true

module Vying
  class AttangleNotation < Notation

    def self.notation_name
      :attangle_notation
    end

    def initialize(game)
      super(game)
      @board_size = game.options[:board_size]
    end

    def to_move(s)
      if s =~ /^\s*(\w\d)\s*$/
        conv(Regexp.last_match(1))
      elsif s =~ /^\s*(\w\d),?(\w\d)-?(\w\d)\s*$/
        conv(Regexp.last_match(1)) +
        conv(Regexp.last_match(2)) +
        conv(Regexp.last_match(3))
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

      if md = s.match(/(\w\d)(\w\d)(\w\d)/)
        "#{md[1]},#{md[2]}-#{md[3]}"
      else
        s
      end
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
