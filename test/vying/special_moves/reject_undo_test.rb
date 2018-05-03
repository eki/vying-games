
# frozen_string_literal: true

require_relative '../../test_helper'

class TestRejectUndo < Minitest::Test
  include Vying

  def sm
    Move::RejectUndo
  end

  def test_wrap
    assert(sm['reject_undo'])

    assert(!sm['undo_requested_by_black'])
    assert(!sm['undo_accepted_by_white'])
    assert(!sm['undo'])

    assert(SpecialMove['reject_undo'])

    assert(sm['reject_undo'].kind_of?(sm))
    assert(SpecialMove['reject_undo'].kind_of?(sm))

    assert(!SpecialMove['undo_requested_by_black'].kind_of?(sm))
    assert(!SpecialMove['undo_accepted_by_white'].kind_of?(sm))
    assert(!SpecialMove['undo'].kind_of?(sm))
  end

  def test_by
    assert_nil(sm['reject_undo'].by)
  end

  def test_valid_for
    american_checkers = Game.new(AmericanCheckers)
    connect6 = Game.new(Connect6)
    othello = Game.new(Othello)

    assert(!sm['reject_undo'].valid_for?(american_checkers))
    assert(!sm['reject_undo'].valid_for?(connect6))

    american_checkers << american_checkers.moves.first
    connect6 << connect6.moves.first

    assert(!sm['reject_undo'].valid_for?(american_checkers))
    assert(!sm['reject_undo'].valid_for?(connect6))

    assert(american_checkers.special_move?('undo_requested_by_white'))
    assert(connect6.special_move?('undo_requested_by_white'))

    american_checkers << 'undo_requested_by_white'
    connect6 << 'undo_requested_by_white'

    assert(sm['reject_undo'].valid_for?(american_checkers))
    assert(sm['reject_undo'].valid_for?(connect6))
  end

  def test_effects_history
    assert(!sm['reject_undo'].effects_history?)
  end

end
