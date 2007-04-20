require 'test/unit'

require 'vying'
require 'vying/rules/rules_test'

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
    g = Game.new( Hearts )
    assert_equal( Card[:C2], g.ops.first )
    assert( g.op?( Card[:C2] ) )
    assert( g.op?( :C2 ) )
  end

  def test_shoot_moon
    g = Game.new( Hearts, 7319 )
    g <<  [:C2, :C7, :CA, :CQ, :SA, :S4, :S2, :S3, :S7, :ST, :SK, :S8,
           :SJ, :SQ, :S6, :S9, :D2, :DQ, :D8, :DA, :DJ, :D3, :DT, :D4,
           :D6, :D9, :D7, :HK, :DK, :HQ, :H9, :HJ, :D5, :HT, :H3, :H6, 
           :HA, :H7, :C9, :H5, :H8, :H2, :C6, :CJ, :H4, :CT, :C5, :C4,
           :CK, :C8, :C3]

    assert_equal( 0, g.score( :n ) )
    assert_equal( 0, g.score( :s ) )
    assert_equal( 0, g.score( :e ) )
    assert_equal( 0, g.score( :w ) )

    g << :S5

    assert_equal( 26, g.score( :n ) )
    assert_equal( 26, g.score( :s ) )
    assert_equal( 0, g.score( :e ) )
    assert_equal( 26, g.score( :w ) )
  end
end

