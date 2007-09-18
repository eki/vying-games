require 'vying/ai/bot'

module AI::Breakthrough

  def eval_distance( position, player )
    b, score = position.board, 0

    position.players.each do |p|
      ty = 0
      pc = 0

      b.occupied[p].each do |c|
        ty += c.y
        pc += 1
      end

      ay = pc > 0 ? ty / pc : 0

      ps = p == :black ? ay : 8 - ay

      score += ps if p == player
      score -= ps if p != player
    end

    score
  end

  def eval_most_advanced( position, player )
    opp = player == :black ? :white : :black
    b = position.board

    score = 0

    position.players.each do |p|
      p_my = 0
      b.occupied[p].each do |c|
        p_my = c.y   if p == :black && c.y > p_my
        p_my = 8-c.y if p == :white && 8-c.y > p_my
      end

      score += 10 * p_my if p == player
      score -= 10 * p_my if p == opp
    end

    score
  end

  def eval_captures( position, player )
    opp = player == :black ? :white : :black
    b = position.board

    (b.occupied[player].length - b.occupied[opp].length) * 5
  end

  module Bot
    include AI::Breakthrough
    include AlphaBeta

    attr_reader :nodes, :leaf

    def initialize
      super
    end

    def select( sequence, position, player )
      return position.ops.first if position.ops.length == 1

      @leaf, @nodes = 0, 0
      score, op = fuzzy_best( analyze( position, player ), 1 )
      puts "**** Searched #{nodes}:#{leaf} positions, best: #{score}"

      op
    end

    def evaluate( position, player )
      @leaf += 1

      return  1000 if position.final? && position.winner?( player )
      return -1000 if position.final? && position.loser?( player )
      return     0 if position.final?

      eval( position, player )
    end

    def cutoff( position, depth )
      position.final? || depth >= 2
    end
  end
end

