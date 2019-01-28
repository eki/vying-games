# frozen_string_literal: true

require_relative '../../test_helper'

class TestKick < Minitest::Test
  include Vying

  def sm
    Move::Kick
  end

  def test_wrap
    assert(sm['kick_black'])
    assert(sm['kick_x'])

    assert(!sm['undo_accepted_by_black'])
    assert(!sm['kick'])
    assert(!sm['_kick'])

    assert(SpecialMove['kick_black'])
    assert(SpecialMove['kick_x'])

    assert(!SpecialMove['kick'])
    assert(!SpecialMove['_kick'])

    assert(sm['kick_black'].kind_of?(sm))
    assert(sm['kick_x'].kind_of?(sm))

    assert(!sm['undo_accepted_by_black'].kind_of?(sm))
    assert(!sm['kick'].kind_of?(sm))

    assert(SpecialMove['kick_black'].kind_of?(sm))
    assert(SpecialMove['kick_x'].kind_of?(sm))

    assert(!SpecialMove['undo_accepted_by_black'].kind_of?(sm))
    assert(!SpecialMove['kick'].kind_of?(sm))
  end

  def test_by
    assert_nil(sm['kick_black'].by)
    assert_nil(sm['kick_x'].by)
  end

  def test_target
    assert_equal(:black, sm['kick_black'].target)
    assert_equal(:x, sm['kick_x'].target)
  end

  def test_valid_for
    ttt = Game.new(TicTacToe)

    assert(!sm['kick_x'].valid_for?(ttt))
    assert(!sm['kick_o'].valid_for?(ttt))

    assert(!sm['kick_x'].valid_for?(ttt, :x))
    assert(!sm['kick_o'].valid_for?(ttt, :x))

    assert(!sm['kick_x'].valid_for?(ttt, :o))
    assert(!sm['kick_o'].valid_for?(ttt, :o))

    ttt.instance_variable_set('@unrated', true)

    assert(!sm['kick_x'].valid_for?(ttt))
    assert(!sm['kick_o'].valid_for?(ttt))

    assert(!sm['kick_x'].valid_for?(ttt, :x))
    assert(!sm['kick_o'].valid_for?(ttt, :x))

    assert(!sm['kick_x'].valid_for?(ttt, :o))
    assert(!sm['kick_o'].valid_for?(ttt, :o))

    ttt[:x].user = Human.new('dude')

    assert(sm['kick_x'].valid_for?(ttt))
    assert(!sm['kick_o'].valid_for?(ttt))

    assert(!sm['kick_x'].valid_for?(ttt, :x))
    assert(!sm['kick_o'].valid_for?(ttt, :x))

    assert(!sm['kick_x'].valid_for?(ttt, :o))
    assert(!sm['kick_o'].valid_for?(ttt, :o))

    ttt[:o].user = Human.new('dudette')

    assert(sm['kick_x'].valid_for?(ttt))
    assert(sm['kick_o'].valid_for?(ttt))

    assert(!sm['kick_x'].valid_for?(ttt, :x))
    assert(sm['kick_o'].valid_for?(ttt, :x))

    assert(sm['kick_x'].valid_for?(ttt, :o))
    assert(!sm['kick_o'].valid_for?(ttt, :o))

    ttt.instance_variable_set('@unrated', false)

    assert(!sm['kick_x'].valid_for?(ttt))
    assert(!sm['kick_o'].valid_for?(ttt))

    assert(!sm['kick_x'].valid_for?(ttt, :x))
    assert(!sm['kick_o'].valid_for?(ttt, :x))

    assert(!sm['kick_x'].valid_for?(ttt, :o))
    assert(!sm['kick_o'].valid_for?(ttt, :o))
  end

  def test_effects_history
    assert(!sm['kick_red'].effects_history?)
  end

  def test_generate_for
    ttt = Game.new(TicTacToe)

    assert(!sm.generate_for(ttt).include?('kick_x'))
    assert(!sm.generate_for(ttt).include?('kick_o'))

    assert(!sm.generate_for(ttt, :x).include?('kick_x'))
    assert(!sm.generate_for(ttt, :x).include?('kick_o'))

    assert(!sm.generate_for(ttt, :o).include?('kick_x'))
    assert(!sm.generate_for(ttt, :o).include?('kick_o'))

    ttt.instance_variable_set('@unrated', true)

    assert(!sm.generate_for(ttt).include?('kick_x'))
    assert(!sm.generate_for(ttt).include?('kick_o'))

    assert(!sm.generate_for(ttt, :x).include?('kick_x'))
    assert(!sm.generate_for(ttt, :x).include?('kick_o'))

    assert(!sm.generate_for(ttt, :o).include?('kick_x'))
    assert(!sm.generate_for(ttt, :o).include?('kick_o'))

    ttt[:x].user = Human.new('dude')

    assert(sm.generate_for(ttt).include?('kick_x'))
    assert(!sm.generate_for(ttt).include?('kick_o'))

    assert(!sm.generate_for(ttt, :x).include?('kick_x'))
    assert(!sm.generate_for(ttt, :x).include?('kick_o'))

    assert(!sm.generate_for(ttt, :o).include?('kick_x'))
    assert(!sm.generate_for(ttt, :o).include?('kick_o'))

    ttt[:o].user = Human.new('dudette')

    assert(sm.generate_for(ttt).include?('kick_x'))
    assert(sm.generate_for(ttt).include?('kick_o'))

    assert(!sm.generate_for(ttt, :x).include?('kick_x'))
    assert(sm.generate_for(ttt, :x).include?('kick_o'))

    assert(sm.generate_for(ttt, :o).include?('kick_x'))
    assert(!sm.generate_for(ttt, :o).include?('kick_o'))

    ttt.instance_variable_set('@unrated', false)

    assert(!sm.generate_for(ttt).include?('kick_x'))
    assert(!sm.generate_for(ttt).include?('kick_o'))

    assert(!sm.generate_for(ttt, :x).include?('kick_x'))
    assert(!sm.generate_for(ttt, :x).include?('kick_o'))

    assert(!sm.generate_for(ttt, :o).include?('kick_x'))
    assert(!sm.generate_for(ttt, :o).include?('kick_o'))
  end

end
