$:.unshift File.join( File.dirname( __FILE__ ), ".." )

require 'game'
require 'search'

class ExhaustiveBot

  def ExhaustiveBot.select( game )
    #These two lines work
    #minimax = Minimax.new( game.rules )
    #score,op = minimax.search( game.history.last )

    #Or these two lines work
    #negamax = Negamax.new( game.rules )
    #score,op = negamax.search( game.history.last )

    #But do these two lines work?
    alphabeta = AlphaBetaNegamax.new( game.rules )
    score,op = alphabeta.search( game.history.last )

    puts "#{game}\nTaking #{op}: #{score}"

    op.short
  end

end

