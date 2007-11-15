require 'vying/ai/bot'

module AI::NineMensMorris

  def eval_score( position, player )
    opp = player == :black ? :white : :black

    4 * position.score( player ) - position.score( opp )
  end

  def eval_mills( position, player )
    opp = player == :black ? :white : :black

    score = 0

    position.board.occupied[player].each do |c|
      score += 2 if position.mill?( c )
    end

    position.board.occupied[opp].each do |c|
      score -= 2 if position.mill?( c )
    end

    score
  end

  def eval_mobility( position, player )
    moves = position.moves
    moves ? moves.length : 0
  end

  module Bot
    include AI::NineMensMorris
    include AlphaBeta

    attr_reader :nodes, :leaf

    def initialize
      super
    end

    def select( sequence, position, player )
      return position.moves.first if position.moves.length == 1

      @leaf, @nodes = 0, 0
      score, move = fuzzy_best( analyze( position, player ), 1 )
      puts "**** Searched #{nodes}:#{leaf} positions, best: #{score}"

      move
    end

    def evaluate( position, player )
      @leaf += 1

      return  1000 if position.final? && position.winner?( player )
      return -1000 if position.final? && position.loser?( player )
      return     0 if position.final?

      eval( position, player )
    end

    def cutoff( position, depth )
      position.final? || depth >= 4
    end
  end
end

