# frozen_string_literal: true

require_relative '../../test_helper'

class TestAcceptDraw < Minitest::Test
  include Vying::Games

  def sm
    Move::AcceptDraw
  end

  def test_wrap
    assert(sm['draw_accepted_by_black'])
    assert(sm['draw_accepted_by_x'])

    assert(!sm['draw_offered_by_black'])
    assert(!sm['draw_accepted_by'])

    assert(SpecialMove['draw_accepted_by_black'])
    assert(SpecialMove['draw_accepted_by_x'])

    assert(!SpecialMove['draw_accepted_by'])

    assert(sm['draw_accepted_by_black'].kind_of?(sm))
    assert(sm['draw_accepted_by_x'].kind_of?(sm))

    assert(!sm['draw_offered_by_black'].kind_of?(sm))
    assert(!sm['draw_accepted_by'].kind_of?(sm))

    assert(SpecialMove['draw_accepted_by_black'].kind_of?(sm))
    assert(SpecialMove['draw_accepted_by_x'].kind_of?(sm))

    assert(!SpecialMove['draw_offered_by_black'].kind_of?(sm))
    assert(!SpecialMove['draw_accepted_by'].kind_of?(sm))
  end

  def test_by
    assert_equal(:black, sm['draw_accepted_by_black'].by)
    assert_equal(:x, sm['draw_accepted_by_x'].by)
  end

  def test_valid_for
    american_checkers = Game.new(AmericanCheckers)
    connect6 = Game.new(Connect6)

    assert(!sm['draw_accepted_by_red'].valid_for?(american_checkers))
    assert(!sm['draw_accepted_by_black'].valid_for?(connect6))

    american_checkers << 'draw_offered_by_white'
    connect6 << 'draw_offered_by_white'

    assert(sm['draw_accepted_by_red'].valid_for?(american_checkers))
    assert(sm['draw_accepted_by_black'].valid_for?(connect6))
  end

  def test_effects_history
    assert(sm['draw_accepted_by_red'].effects_history?)
  end

end
