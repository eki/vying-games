require 'game'

class GreedyBot < Bot
  def initialize( rules, player )
    super
  end

  def evaluate( position )
    opps = position.players.select { |p| p != player }
    score = position.board.count( player )
    opps.each { |opp| score -= position.board.count( opp ) }
    score
  end
end

