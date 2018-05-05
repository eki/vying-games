
# frozen_string_literal: true

require_relative '../../test_helper'

class TestRejectDraw < Minitest::Test
  include Vying

  def sm
    Move::RejectDraw
  end

  def test_wrap
    assert(sm['reject_draw'])

    assert(!sm['draw_offered_by_black'])
    assert(!sm['draw_accepted_by'])
    assert(!sm['x_withdraws'])

    assert(SpecialMove['reject_draw'])

    assert(sm['reject_draw'].kind_of?(sm))

    assert(!sm['draw_offered_by_black'].kind_of?(sm))
    assert(!sm['x_withdraws'].kind_of?(sm))

    assert(SpecialMove['reject_draw'].kind_of?(sm))

    assert(!SpecialMove['draw_offered_by_black'].kind_of?(sm))
    assert(!SpecialMove['x_withdraws'].kind_of?(sm))
  end

  def test_by
    assert_nil(sm['reject_draw'].by)
  end

  def test_valid_for
    american_checkers = Game.new(AmericanCheckers)
    connect6 = Game.new(Connect6)

    assert(!sm['reject_draw'].valid_for?(american_checkers))
    assert(!sm['reject_draw'].valid_for?(connect6))

    american_checkers << 'draw_offered_by_white'
    connect6 << 'draw_offered_by_white'

    assert(sm['reject_draw'].valid_for?(american_checkers))
    assert(sm['reject_draw'].valid_for?(connect6))
  end

  def test_effects_history
    assert(!sm['reject_draw'].effects_history?)
  end

end
