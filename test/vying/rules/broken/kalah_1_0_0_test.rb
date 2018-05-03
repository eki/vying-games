# frozen_string_literal: true

require_relative '../../../test_helper'

class TestKalah_1_0_0 < Minitest::Test
  include RulesTests

  def rules
    Rules.find Kalah, '1.0.0'
  end

  def test_info
    assert_equal('Kalah', rules.name)
    assert_equal('1.0.0', rules.version)
  end

  def test_players
    assert_equal([:one, :two], rules.new.players)
  end

  def test_initialize
    g = new_game

    b = Board.rect(6, 2, fill: 4)

    assert_equal(b, g.board)
    assert_equal(:one, g.turn)
    assert_equal(0, g.score(:one))
    assert_equal(0, g.score(:two))
  end

  def test_moves
    g = new_game

    assert_equal(:one, g.turn)
    assert_equal(%w(a1 b1 c1 d1 e1 f1), g.moves)

    g << :a1

    assert_equal(:two, g.turn)
    assert_equal(%w(a2 b2 c2 d2 e2 f2), g.moves)

    g << :f2

    assert_equal(:one, g.turn)
    assert_equal(%w(b1 c1 d1 e1 f1), g.moves)

    g << :e1

    assert_equal(:one, g.turn)
    assert_equal(%w(a1 b1 c1 d1 f1), g.moves)

    g << g.moves.first until g.final?

    refute_equal(g.history.first, g.history.last)
  end

  def test_has_score
    g = new_game
    g << g.moves.first

    assert(g.has_score?)
    assert_equal(1, g.score(:one))
    assert_equal(0, g.score(:two))
  end

  def test_capture
    g = new_game
    g << :a1 << :f2

    assert_equal(1, g.score(:one))
    assert_equal(5, g.board[:a2])
    assert_equal(0, g.board[:a1])
    assert_equal(5, g.board[:f1])

    g << :f1

    assert_equal(7, g.score(:one))
    assert_equal(0, g.board[:a2])
    assert_equal(0, g.board[:a1])
    assert_equal(0, g.board[:f1])
  end

  def test_no_capture
    g = new_game

    g << :a1 << :a2

    assert_equal(1, g.score(:one))
    assert_equal(0, g.board[:a2])
    assert_equal(0, g.board[:a1])
    assert_equal(4, g.board[:c1])

    g << :c1

    assert_equal(2, g.score(:one))
    assert_equal(1, g.board[:a2])
    assert_equal(1, g.board[:a1])
    assert_equal(0, g.board[:c1])
  end

  def test_extra_turn
    g = new_game
    g << :a1 << :f2

    assert_equal(:one, g.turn)

    g << :e1

    assert_equal(:one, g.turn)
  end

  def test_final
    g = new_game

    # Doctor the board

    g.board[:b1, :c1, :d1, :e1, :f1] = 0

    assert(!g.final?)
    assert_equal(0, g.score(:one))
    assert_equal(0, g.score(:two))
    assert_equal(['a1'], g.moves)

    g << :a1

    assert(!g.final?) # :one's side is empty, but player two can still move

    g << :a2

    assert(g.final?)
    assert_equal(1, g.score(:one))
    assert_equal(27, g.score(:two))
    assert(!g.winner?(:one))
    assert(g.winner?(:two))
    assert(g.loser?(:one))
    assert(!g.loser?(:two))
    assert(!g.draw?)
  end

end
