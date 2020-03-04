# frozen_string_literal: true

# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying/games/rules'

module Minimax

  def analyze(position, player)
    h = {}
    position.moves.each do |move|
      h[move] = search(position.apply(move), player, 1)
    end
    h
  end

  def search(position, player, depth=0)
    @nodes += 1 if respond_to? :nodes

    return evaluate(position, player) if cutoff(position, depth)

    scores = position.moves.map do |move|
      search(position.apply(move), player, depth + 1)
    end

    position.turn == player ? scores.max : scores.min
  end
end
