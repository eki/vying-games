
# frozen_string_literal: true

require_relative '../../test_helper'

class TestTimeout < Minitest::Test
  include Vying

  def sm
    Move::Timeout
  end

  def test_wrap
    assert(sm['time_exceeded_by_black'])
    assert(sm['time_exceeded_by_x'])

    assert(!sm['undo_accepted_by_black'])
    assert(!sm['time_exceeded_by'])

    assert(SpecialMove['time_exceeded_by_black'])
    assert(SpecialMove['time_exceeded_by_x'])

    assert(!SpecialMove['time_exceeded_by'])

    assert(sm['time_exceeded_by_black'].kind_of?(sm))
    assert(sm['time_exceeded_by_x'].kind_of?(sm))

    assert(!sm['undo_accepted_by_black'].kind_of?(sm))
    assert(!sm['time_exceeded_by'].kind_of?(sm))

    assert(SpecialMove['time_exceeded_by_black'].kind_of?(sm))
    assert(SpecialMove['time_exceeded_by_x'].kind_of?(sm))

    assert(!SpecialMove['undo_accepted_by_black'].kind_of?(sm))
    assert(!SpecialMove['time_exceeded_by'].kind_of?(sm))
  end

  def test_by
    assert_equal(:black, sm['time_exceeded_by_black'].by)
    assert_equal(:x, sm['time_exceeded_by_x'].by)
  end

  def test_valid_for
    ttt = Game.new(TicTacToe)

    assert(sm['time_exceeded_by_x'].valid_for?(ttt))
    assert(sm['time_exceeded_by_o'].valid_for?(ttt))

    assert(!sm['time_exceeded_by_x'].valid_for?(ttt, :x))
    assert(!sm['time_exceeded_by_o'].valid_for?(ttt, :x))

    assert(!sm['time_exceeded_by_x'].valid_for?(ttt, :o))
    assert(!sm['time_exceeded_by_o'].valid_for?(ttt, :o))
  end

  def test_effects_history
    assert(sm['time_exceeded_by_red'].effects_history?)
  end

  def test_generate_for
    ttt = Game.new(TicTacToe)

    assert(sm.generate_for(ttt).include?('time_exceeded_by_x'))
    assert(sm.generate_for(ttt).include?('time_exceeded_by_o'))

    assert(!sm.generate_for(ttt, :x).include?('time_exceeded_by_x'))
    assert(!sm.generate_for(ttt, :x).include?('time_exceeded_by_o'))

    assert(!sm.generate_for(ttt, :o).include?('time_exceeded_by_x'))
    assert(!sm.generate_for(ttt, :o).include?('time_exceeded_by_o'))
  end

end
