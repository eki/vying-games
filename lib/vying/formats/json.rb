# frozen_string_literal: true

module Vying
  class JsonFormat < Format

    def self.type
      :json
    end

    def load(string)
      h = Oj.load(string)

      Vying.load(h, :hash)
    end

    def dump(game)
      Oj.dump(game.to_format(:hash))
    end

  end
end
