
require 'test/unit'
require 'vying'

class TestDraw < Test::Unit::TestCase
  def sm
    Move::Draw
  end

  def test_wrap
    assert( sm["draw"] )

    assert( ! sm["draw_accepted_by_black"] )
    assert( ! sm["draw_offered_by_white"] )
    assert( ! sm["red_withdraws"] )

    assert( SpecialMove["draw"] )

    assert( sm["draw"].kind_of?( sm ) )
    assert( SpecialMove["draw"].kind_of?( sm ) )
  end

  def test_by
    assert_equal( nil, sm["draw"].by )
    assert_equal( nil, sm["draw"].by )
  end

  def test_valid_for
    g = Game.new( Connect6 )

    assert( sm["draw"].valid_for?( g ) )

    assert( ! sm["draw"].valid_for?( g, :black ) )
    assert( ! sm["draw"].valid_for?( g, :white ) )
  end

  def test_effects_history
    assert( sm["draw"].effects_history? )
  end

  def test_generate_for
    g = Game.new( Connect6 )

    assert( sm.generate_for( g ).include?( sm["draw"] ) )

    assert( ! sm.generate_for( g, :black ).include?( sm["draw"] ) )
    assert( ! sm.generate_for( g, :white ).include?( sm["draw"] ) )
  end

end

