# frozen_string_literal: true

require_relative '../../../test_helper'

class TestAttangle < Minitest::Test
  include RulesTests

  def rules
    Attangle
  end

  def test_info
    assert_equal('Attangle', rules.name)
    assert(rules.version == '1.0.0')
    assert(rules.highest_score_determines_winner?)
  end

  def test_players
    assert_equal([:white, :black], rules.new.players)
  end

  def test_initialize
    g = Game.new(rules)

    assert_equal(37, g.board.unoccupied.length)
    assert_equal(18, g.pool[:white])
    assert_equal(18, g.pool[:black])
    assert_equal(:white, g.turn)
  end

  def test_options
    assert_equal(4, rules.options[:board_size].default)
    assert_equal([3, 4, 5, 6], rules.options[:board_size].values)

    assert_equal(4, rules.new.board.length)
    assert_equal(3, rules.new(board_size: 3).board.length)
    assert_equal(4, rules.new(board_size: 4).board.length)
    assert_equal(5, rules.new(board_size: 5).board.length)
    assert_equal(6, rules.new(board_size: 6).board.length)

    assert_raises(RuntimeError) { rules.new(board_size: 2) }
    assert_raises(RuntimeError) { rules.new(board_size: 7) }
  end

  def test_has_moves
    g = Game.new(rules)
    assert_equal([:white], g.has_moves)
    g << g.moves.first
    assert_equal([:black], g.has_moves)
  end

  def test_play
    g = Game.new(rules)

    assert_equal(36, g.moves.length)
    assert_raises(RuntimeError) { g << 'd4' }

    g << 'a1'
    assert_equal([:white], g.board[:a1])
    assert_equal(17, g.pool[:white])
    assert_equal(18, g.pool[:black])

    assert_raises(RuntimeError) { g << 'a1' }
    g << 'c3'
    assert_equal([:black], g.board[:c3])
    assert_equal(17, g.pool[:white])
    assert_equal(17, g.pool[:black])

    g << 'e3' << 'g7'

    g << 'a1e3c3'
    assert_nil(g.board[:a1])
    assert_nil(g.board[:e3])
    assert_equal([:white, :black], g.board[:c3])
    assert_equal(17, g.pool[:white])
    assert_equal(16, g.pool[:black])

    g << 'a1' << 'd7'

    assert_raises(RuntimeError) { g << 'c3d7g7' }
    g << 'c1'

    g << 'c3d7g7'
    assert_equal(1, g.score(:white))
    assert_equal(0, g.score(:black))

    # TODO: more moves until winning position for :white
    # test for outcome
  end

end
