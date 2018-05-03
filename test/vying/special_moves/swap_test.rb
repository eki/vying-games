
require_relative '../../test_helper'

class TestSwap < Minitest::Test
  include Vying

  def sm
    Move::Swap
  end

  def test_wrap
    assert( sm["swap"] )

    assert( ! sm["draw_accepted_by_black"] )
    assert( ! sm["draw_offered_by_white"] )
    assert( ! sm["red_withdraws"] )

    assert( SpecialMove["swap"] )

    assert( sm["swap"].kind_of?( sm ) )
    assert( SpecialMove["swap"].kind_of?( sm ) )
  end

  def test_by
    assert_equal( nil, sm["swap"].by )
    assert_equal( nil, sm["swap"].by )
  end

  def test_valid_for
    g = Game.new( Kalah )

    assert( ! sm["swap"].valid_for?( g ) )

    assert( ! sm["swap"].valid_for?( g, :one ) )
    assert( ! sm["swap"].valid_for?( g, :two ) )

    g << "c1"

    assert( sm["swap"].valid_for?( g ) )

    assert( ! sm["swap"].valid_for?( g, :one ) )
    assert( sm["swap"].valid_for?( g, :two ) )

    g << g.moves.first

    assert( ! sm["swap"].valid_for?( g ) )

    assert( ! sm["swap"].valid_for?( g, :one ) )
    assert( ! sm["swap"].valid_for?( g, :two ) )
  end

  def test_effects_history
    assert( sm["swap"].effects_history? )
  end

  def test_generate_for
    g = Game.new( Kalah )

    assert( ! sm.generate_for( g ).include?( sm["swap"] ) )

    assert( ! sm.generate_for( g, :one ).include?( sm["swap"] ) )
    assert( ! sm.generate_for( g, :two ).include?( sm["swap"] ) )

    g << "c1"

    assert( sm.generate_for( g ).include?( sm["swap"] ) )

    assert( ! sm.generate_for( g, :one ).include?( sm["swap"] ) )
    assert( sm.generate_for( g, :two ).include?( sm["swap"] ) )

    g << g.moves.first

    assert( ! sm.generate_for( g ).include?( sm["swap"] ) )

    assert( ! sm.generate_for( g, :one ).include?( sm["swap"] ) )
    assert( ! sm.generate_for( g, :two ).include?( sm["swap"] ) )
  end

end

