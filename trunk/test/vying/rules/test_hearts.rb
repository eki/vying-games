require 'test/unit'

require 'vying'
require 'vying/rules/test_rules'

class TestHearts < Test::Unit::TestCase
  include RulesTests

  def rules
    Hearts
  end

  def test_info
    assert_equal( "Hearts", Hearts.info[:name] )
  end

  def test_players
    assert_equal( [:n,:e,:s,:w], Hearts.players )
    assert_equal( [:n,:e,:s,:w], Hearts.new.players )
  end

  def test_initialize       # Need to be more thorough here
    g = Game.new( Hearts )
    assert_equal( [Card[:C2]], g.ops )
  end

  def test_has_ops
  end

  def test_ops
  end
end

