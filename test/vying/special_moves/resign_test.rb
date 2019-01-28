# frozen_string_literal: true

require_relative '../../test_helper'

class TestResign < Minitest::Test
  include Vying

  def sm
    Move::Resign
  end

  def test_wrap
    assert(sm['black_resigns'])
    assert(sm['x_resigns'])

    assert(!sm['resign'])
    assert(!sm['black_withdraws'])

    assert(SpecialMove['black_resigns'])
    assert(SpecialMove['x_resigns'])

    assert(!SpecialMove['resign'])

    assert(sm['black_resigns'].kind_of?(sm))
    assert(sm['x_resigns'].kind_of?(sm))

    assert(!sm['undo_accepted_by_black'].kind_of?(sm))

    assert(SpecialMove['black_resigns'].kind_of?(sm))
    assert(SpecialMove['x_resigns'].kind_of?(sm))

    assert(!SpecialMove['undo_accepted_by_black'].kind_of?(sm))
  end

  def test_by
    assert_equal(:black, sm['black_resigns'].by)
    assert_equal(:x, sm['x_resigns'].by)
  end

  def test_valid_for
    g = Game.new(TicTacToe)

    assert(sm['x_resigns'].valid_for?(g))
    assert(sm['o_resigns'].valid_for?(g))

    assert(sm['x_resigns'].valid_for?(g, :x))
    assert(!sm['o_resigns'].valid_for?(g, :x))

    assert(!sm['x_resigns'].valid_for?(g, :o))
    assert(sm['o_resigns'].valid_for?(g, :o))

    g << g.moves.first

    g << 'undo_requested_by_x'

    assert(!sm['x_resigns'].valid_for?(g))
    assert(!sm['o_resigns'].valid_for?(g))

    assert(!sm['x_resigns'].valid_for?(g, :x))
    assert(!sm['o_resigns'].valid_for?(g, :x))

    assert(!sm['x_resigns'].valid_for?(g, :o))
    assert(!sm['o_resigns'].valid_for?(g, :o))
  end

  def test_effects_history
    assert(sm['black_resigns'].effects_history?)
  end

  def test_generate_for
    g = Game.new(TicTacToe)

    assert(sm.generate_for(g).include?('x_resigns'))
    assert(sm.generate_for(g).include?('o_resigns'))

    assert(sm.generate_for(g, :x).include?('x_resigns'))
    assert(!sm.generate_for(g, :x).include?('o_resigns'))

    assert(!sm.generate_for(g, :o).include?('x_resigns'))
    assert(sm.generate_for(g, :o).include?('o_resigns'))

    g << g.moves.first

    g << 'undo_requested_by_x'

    assert(!sm.generate_for(g).include?('x_resigns'))
    assert(!sm.generate_for(g).include?('o_resigns'))

    assert(!sm.generate_for(g, :x).include?('x_resigns'))
    assert(!sm.generate_for(g, :x).include?('o_resigns'))

    assert(!sm.generate_for(g, :o).include?('x_resigns'))
    assert(!sm.generate_for(g, :o).include?('o_resigns'))
  end

end
