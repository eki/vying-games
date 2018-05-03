# frozen_string_literal: true

# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying/rules'

module AlphaBeta
  def analyze(position, player)
    h = {}

    moves = prune(position, player, position.moves) if respond_to? :prune
    moves ||= position.moves

    p2m = {}
    moves.each { |m| p2m[position.apply(m)] = m }

    positions = p2m.keys

    if respond_to?(:order)
      positions = order(positions, player)
    else
      positions = order_by_cache(positions, player)
    end

    positions.each do |p|
      h[p2m[p]] = search(p, player, -10**10, 10**10, 1).first
    end
    h
  end

  def search(position, player, a, b, depth=0)
    if cache.include?(position, player, depth)
      return cache.get(position, player)
    end

    @nodes += 1 if respond_to? :nodes

    if cutoff(position, depth)
      score = evaluate(position, player)
      distance = position.final? ? 10**10 : 0
      cache.put(position, player, score, distance)
      return [score, distance]
    end

    scores = successors(position, player).map do |p|
      v, d = search(p, player, a, b, depth + 1)

      # Check for alpha-beta cutoffs
      if position.turn == player
        a = [a, v].max
        return [b, d] if a >= b
      elsif position.turn != player
        b = [b, v].min
        return [a, d] if b <= a
      end

      [v, d]
    end

    if position.turn == player
      score, distance = scores.max_by(&:first)
    else
      score, distance = scores.min_by(&:first)
    end

    cache.put(position, player, score, distance + 1)
  end

  def successors(position, player)
    if respond_to?(:prune)
      moves = prune(position, player, position.moves)
      moves ||= position.moves
      ss = moves.map { |move| position.apply(move) }
    else
      ss = position.successors
    end

    if respond_to?(:order)
      ss = order(ss, player)
    else
      ss = order_by_cache(ss, player)
    end

    ss
  end

  def order_by_cache(positions, player)
    positions.sort_by do |p|
      a = cache.get(p, player)
      a ? a.first : 0
    end
  end
end
