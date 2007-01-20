require 'test/unit'

require 'vying'

class TestBot < Bot
  include AI::Othello::Bot
end

class TestBotsOthello < Test::Unit::TestCase

  def test_openings
    b = TestBot.new

    g = Game.new( Othello )
    g << :f5 << :f6 << :e6 << :f4 << :e3
   
    assert_equal( 395, b.openings.length )

    op = b.opening( g.history.last, g.sequence )
    assert( op )

    assert( ['c5','d6'].include?( op ) )

  end

end

