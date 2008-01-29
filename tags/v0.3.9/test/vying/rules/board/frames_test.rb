require 'test/unit'

require 'vying'
require 'vying/rules/rules_test'

class TestFrames < Test::Unit::TestCase
  include RulesTests

  def rules
    Frames
  end

  def test_info
    assert_equal( "Frames", Frames.info[:name] )
  end

  def test_players
    assert_equal( [:black,:white], Frames.players )
    assert_equal( [:black,:white], Frames.new.players )
  end

  def test_initialize       # Need to be more thorough here
    g = Game.new( Frames )
    assert_equal( [:black, :white], g.has_moves )
  end

end

