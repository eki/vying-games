require 'vying/ai/bot'
require 'vying/ai/search'

class GreedyBot < Bot
  include Minimax

  attr_reader :leaf, :nodes

  def initialize
    super
    @leaf = 0
    @nodes = 0
  end

  def select( position, player )
    @leaf, @nodes = 0, 0
    score, op = best( analyze( position, player ) )
    #puts "**** Searched #{nodes}:#{leaf} positions, best: #{score}"
    op
  end

  def evaluate( position, player )
    @leaf += 1
    opps = position.players.select { |p| p != player }
    score = position.board.count( player )
    opps.each { |opp| score -= position.board.count( opp ) }
    score
  end

  def cutoff( position, depth )
    position.final? || depth >= 2
  end

end

