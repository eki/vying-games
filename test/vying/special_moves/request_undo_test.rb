# frozen_string_literal: true

require_relative '../../test_helper'

class TestRequestUndo < Minitest::Test
  include Vying::Games

  def sm
    Move::RequestUndo
  end

  def test_wrap
    assert(sm['undo_requested_by_black'])
    assert(sm['undo_requested_by_x'])

    assert(!sm['undo_accepted_by_black'])
    assert(!sm['undo_requested_by'])

    assert(SpecialMove['undo_requested_by_black'])
    assert(SpecialMove['undo_requested_by_x'])

    assert(!SpecialMove['undo_requested_by'])

    assert(sm['undo_requested_by_black'].kind_of?(sm))
    assert(sm['undo_requested_by_x'].kind_of?(sm))

    assert(!sm['undo_accepted_by_black'].kind_of?(sm))
    assert(!sm['undo_requested_by'].kind_of?(sm))

    assert(SpecialMove['undo_requested_by_black'].kind_of?(sm))
    assert(SpecialMove['undo_requested_by_x'].kind_of?(sm))

    assert(!SpecialMove['undo_accepted_by_black'].kind_of?(sm))
    assert(!SpecialMove['undo_requested_by'].kind_of?(sm))
  end

  def test_by
    assert_equal(:black, sm['undo_requested_by_black'].by)
    assert_equal(:x, sm['undo_requested_by_x'].by)
  end

  def test_valid_for
    ttt = Game.new(TicTacToe)

    assert(!sm['undo_requested_by_x'].valid_for?(ttt))
    assert(!sm['undo_requested_by_o'].valid_for?(ttt))

    ttt << ttt.moves.first

    assert(sm['undo_requested_by_x'].valid_for?(ttt))
    assert(sm['undo_requested_by_o'].valid_for?(ttt))

    amazons = Game.new(Amazons)
    t = amazons.turn

    assert_equal(t, amazons.turn)
    assert(!sm['undo_requested_by_black'].valid_for?(amazons))
    assert(!sm['undo_requested_by_white'].valid_for?(amazons))

    amazons << amazons.moves.first

    assert_equal(t, amazons.turn)
    assert(!sm['undo_requested_by_black'].valid_for?(amazons))
    assert(!sm['undo_requested_by_white'].valid_for?(amazons))

    amazons << amazons.moves.first

    refute_equal(t, amazons.turn)
    assert(sm['undo_requested_by_black'].valid_for?(amazons))
    assert(sm['undo_requested_by_white'].valid_for?(amazons))
  end

  def test_effects_history
    assert(sm['undo_requested_by_red'].effects_history?)
  end

end
