# frozen_string_literal: true

require_relative '../../../test_helper'

class TestAtaxx_1_0_0 < Minitest::Test
  include RulesTests

  def rules
    Rules.find('Ataxx', '1.0.0')
  end

  def test_info
    assert_equal('Ataxx', rules.name)
    assert_equal('1.0.0', rules.version)
    assert(rules.random?)
    assert(rules.deterministic?)
  end

  def test_initialize
    g = Game.new(rules)

    assert_equal(7, g.board.width)
    assert_equal(7, g.board.height)
    assert_equal([:red, :red], g.board[:a1, :g7])
    assert_equal([:blue, :blue], g.board[:a7, :g1])
    assert_equal(2, g.board.occupied(:red).length)
    assert_equal(2, g.board.occupied(:blue).length)
    assert_equal(:red, g.turn)
  end

  def test_moves
    g = Game.new(rules)
    g.clear_blocks
    g.set_blocks('')

    moves = g.moves

    assert_equal(%w(a1b1 a1a2 a1b2
                   g7f6 g7g6 g7f7
                   a1c1 a1c2 a1a3 a1b3 a1c3
                   g7e5 g7f5 g7g5 g7e6 g7e7).sort,
                  moves.map(&:to_s).sort)

    g << g.moves.first until g.final?

    refute_equal(g.history.first, g.history.last)
  end

  def test_players
    assert_equal([:red, :blue], rules.new.players)
  end

  def test_has_score
    g = Game.new(rules)
    g.clear_blocks
    g.set_blocks('')

    g << 'a1a2'

    assert(g.has_score?)
    assert_equal(3, g.score(:red))
    assert_equal(2, g.score(:blue))
  end
end
