require 'test/unit'

require 'vying'

class TestBot < Bot
  include OthelloStrategies
  include AlphaBeta

  def initialize
    super
    @leaf, @nodes = 0, 0
    load_openings
  end

  def select( sequence, position, player )
    return position.moves.first if position.moves.length == 1

    if( move = opening( position, sequence ) )
      puts "**** Taking opening #{sequence.join}:#{move}"
      return move
    end

    @leaf, @nodes = 0, 0
    score, move = best( analyze( position, player ) )
    puts "**** Searched #{nodes}:#{leaf} positions, best: #{score}"
    move
  end

  def evaluate( position, player )
    pc, oc, total, score = eval_count( position, player )

    return score * 1000 if position.final?

    score
  end

  def cutoff( position, depth )
    position.final? || depth >= 2
  end

end

class TestBotsOthello < Test::Unit::TestCase

  def test_openings
    b = TestBot.new

    g = Game.new( Othello )
    g << :f5 << :f6 << :e6 << :f4 << :e3
   
    assert_equal( 395, b.openings.length )

    move = b.opening( g.history.last, g.sequence )
    assert( move )

    assert( ['c5','d6'].include?( move ) )
  end

  def test_eval_count
    b = TestBot.new

    g = Game.new( Othello )
    g << g.moves.first until g.final?

    pc, oc, total, score = b.eval_count( g.history.first, :black )
    assert_equal( 2, pc )
    assert_equal( 2, oc )
    assert_equal( 4, total )
    assert_equal( 0, score )

    b_pc, b_oc, b_total, b_score = b.eval_count( g.history.last, :black )
    w_pc, w_oc, w_total, w_score = b.eval_count( g.history.last, :white )

    #assert_equal( g.history.last.score( :black ), b_score )
    #assert_equal( g.history.last.score( :white ), w_score )
    assert_equal( b_total, w_total )
  end

end

