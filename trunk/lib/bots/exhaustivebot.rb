$:.unshift File.join( File.dirname( __FILE__ ), ".." )

require 'game'
require 'search'

class ExhaustiveBot

  def ExhaustiveBot.select( game )
    minimax = Minimax.new( game.rules )
    score,op = minimax.search( game.history.last )
    op.short
  end

end

