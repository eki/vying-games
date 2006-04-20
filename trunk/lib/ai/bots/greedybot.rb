require 'game'

class GreedyBot < Bot
  def initialize( game, player )
    super( game, player )
  end

  def select
    ops = game.ops
    scores = ops.map do |op| 
      pos = game.rules.apply( game.history.last, op )
      opps = game.players.select { |p| p != player }
      score = pos.board.count( player )
      opps.each { |opp| score -= pos.board.count( opp ) }
      score
    end

    all = scores.zip( ops ).sort
    all.sort.last[1]
  end
end

