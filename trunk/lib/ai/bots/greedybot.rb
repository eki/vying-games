require 'game'
require 'ai/search'

class GreedyBot < Bot
  include Minimax

  attr_reader :leaf, :nodes

  def initialize( rules, player )
    super
    @leaf = 0
    @nodes = 0
  end

  def select( position )
    @leaf, @nodes = 0, 0
    score, op = best( analyze( position ) )
    puts "**** Searched #{nodes}:#{leaf} positions, best: #{score}"
    op
  end

  def evaluate( position )
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

