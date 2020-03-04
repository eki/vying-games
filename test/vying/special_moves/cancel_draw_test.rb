# frozen_string_literal: true

require_relative '../../test_helper'

class TestCancelDraw < Minitest::Test
  include Vying::Games

  def sm
    Move::CancelDraw
  end

  def test_wrap
    assert(sm['cancel_draw'])

    assert(!sm['draw_canceled_by_black'])
    assert(!sm['draw_canceled_by'])
    assert(!sm['x_withdraws'])

    assert(SpecialMove['cancel_draw'])

    assert(sm['cancel_draw'].kind_of?(sm))

    assert(SpecialMove['cancel_draw'].kind_of?(sm))
  end

  def test_by
    assert_nil(sm['cancel_draw'].by)
  end

  def test_valid_for
    american_checkers = Game.new(AmericanCheckers)
    connect6 = Game.new(Connect6)
    othello = Game.new(Othello)

    assert(!sm['cancel_draw'].valid_for?(american_checkers))
    assert(!sm['cancel_draw'].valid_for?(connect6))
    assert(!sm['cancel_draw'].valid_for?(othello))

    american_checkers << 'draw_offered_by_white'
    connect6 << 'draw_offered_by_white'

    assert(sm['cancel_draw'].valid_for?(american_checkers))
    assert(sm['cancel_draw'].valid_for?(connect6))
  end

  def test_effects_history
    assert(!sm['cancel_draw'].effects_history?)
  end

end
