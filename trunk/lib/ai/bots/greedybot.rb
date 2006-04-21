require 'game'

class GreedyBot < Bot
  def initialize( game, player )
    super( game, player )
  end

  def evaluate( position )
    opps = game.players.select { |p| p != player }
    score = position.board.count( player )
    opps.each { |opp| score -= position.board.count( opp ) }
    score
  end
end

