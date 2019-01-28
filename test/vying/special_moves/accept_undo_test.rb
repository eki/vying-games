# frozen_string_literal: true

require_relative '../../test_helper'

class TestAcceptUndo < Minitest::Test
  include Vying

  def sm
    Move::AcceptUndo
  end

  def test_wrap
    assert(sm['undo_accepted_by_black'])
    assert(sm['undo_accepted_by_x'])

    assert(!sm['undo_requested_by_black'])
    assert(!sm['undo_accepted_by'])

    assert(SpecialMove['undo_accepted_by_black'])
    assert(SpecialMove['undo_accepted_by_x'])

    assert(!SpecialMove['undo_accepted_by'])

    assert(sm['undo_accepted_by_black'].kind_of?(sm))
    assert(sm['undo_accepted_by_x'].kind_of?(sm))

    assert(!sm['undo_requested_by_black'].kind_of?(sm))
    assert(!sm['undo_accepted_by'].kind_of?(sm))

    assert(SpecialMove['undo_accepted_by_black'].kind_of?(sm))
    assert(SpecialMove['undo_accepted_by_x'].kind_of?(sm))

    assert(!SpecialMove['undo_requested_by_black'].kind_of?(sm))
    assert(!SpecialMove['undo_accepted_by'].kind_of?(sm))
  end

  def test_by
    assert_equal(:black, sm['undo_accepted_by_black'].by)
    assert_equal(:x, sm['undo_accepted_by_x'].by)
  end

  def test_valid_for
    american_checkers = Game.new(AmericanCheckers)
    connect6 = Game.new(Connect6)

    assert(!sm['undo_accepted_by_red'].valid_for?(american_checkers))
    assert(!sm['undo_accepted_by_black'].valid_for?(connect6))

    american_checkers << american_checkers.moves.first
    connect6 << connect6.moves.first

    assert(!sm['undo_accepted_by_red'].valid_for?(american_checkers))
    assert(!sm['undo_accepted_by_black'].valid_for?(connect6))

    assert(american_checkers.special_move?('undo_requested_by_white'))
    assert(connect6.special_move?('undo_requested_by_white'))

    american_checkers << 'undo_requested_by_white'
    connect6 << 'undo_requested_by_white'

    assert(sm['undo_accepted_by_red'].valid_for?(american_checkers))
    assert(sm['undo_accepted_by_black'].valid_for?(connect6))
  end

  def test_effects_history
    assert(sm['undo_accepted_by_red'].effects_history?)
  end

end
