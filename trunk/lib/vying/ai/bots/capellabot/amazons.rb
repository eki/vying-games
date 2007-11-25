# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying/ai/bot'
require 'vying/ai/search'
require 'vying/ai/strategies/amazons/amazons'

class CapellaBot < Bot
  class Amazons < Bot
    include AlphaBeta
    include AmazonsStrategies

    difficulty :easy

    attr_reader :leaf, :nodes

    def initialize
      super
      @leaf, @nodes = 0, 0
    end

    def select( sequence, position, player )
      return position.moves.first if position.moves.length == 1

      @leaf, @nodes = 0, 0
      score, move = fuzzy_best( analyze( position, player ), 0 )
      puts "**** Searched #{nodes}:#{leaf} positions, best: #{score}"
      move
    end

    def forfeit?( sequence, position, player )
      opp = player == :black ? :white : :black
      territories = position.board.territories

      territories.all? { |t| t.black.empty? || t.white.empty? } &&
      position.score( opp ) > position.score( player )
    end

    def evaluate( position, player )
      eval_neighbors( position, player )
    end

    def cutoff( position, depth )
      position.final? || depth >= 1
    end

    def prune( position, player, moves )
      opp = player == :black ? :white : :black
      pq = []

      position.board.territories.each do |t|
        qs = t.send( player )
        pq += qs if !qs.empty? && t.send( opp ).empty?
      end

      return moves if pq.empty?

      keep = moves.select do |m|
        cs = m.to_coords
        ! pq.include?( cs.first )
      end

      keep.empty? ? moves : keep
    end

  end
end

