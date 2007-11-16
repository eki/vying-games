require 'test/unit'

require 'vying'

module BotTemplate
  include OthelloStrategies

  attr_reader :leaf, :nodes, :leaf_list, :nodes_list
  attr_accessor :depth

  def initialize
    super
    @leaf = 0
    @nodes = 0
  end

  # select should also take a sequence argument, but we wouldn't have
  # used it anyway (we're only interested in search results)

  def select( position, player )
    @leaf, @nodes = 0, 0
    score, move = best( analyze( position, player ) )
    [score, move]           #This should just return move in a real Bot
  end                       #But we're only interested search results
  
  def evaluate( position, player )
    @leaf += 1
    return eval_count( position, player )[3]
  end
                                                              
  def cutoff( position, depth )                               
    position.final? || depth >= @depth 
  end
end

class MiniMaxBot < Bot
  include BotTemplate
  include Minimax
end

class AlphaBetaBot < Bot
  include BotTemplate
  include AlphaBeta
end

class PlayFirstOpBot < Bot
  def select( sequence, position, player )
    position.moves.first
  end
end


class TestSearch < Test::Unit::TestCase
  def test_alphabeta
    mini = MiniMaxBot.new
    alpha = AlphaBetaBot.new

    g = Game.new( Othello )
    g.register_users :black => PlayFirstOpBot.new, :white => PlayFirstOpBot.new
    g.play

    assert( g.history.length > 58 )

    ps = { 0 => 3,
           1 => 3,
           5 => 2,
           30 => 1,
           31 => 2,
           53 => 6,
           58 => 7 }

    ps.each do |i, depth|
      position = g.history[i]
      mini.depth = depth
      alpha.depth = depth

      m_score, m_move = mini.select( position, position.turn )
      a_score, a_move = alpha.select( position, position.turn )

      assert_equal( m_score, a_score )
      assert_equal( m_move, a_move )
      assert( mini.leaf >= alpha.leaf )
      assert( mini.nodes >= alpha.nodes )
    end
  end

end

