# frozen_string_literal: true

require_relative '../../../../test_helper'

class TestYavalath < Minitest::Test
  include RulesTests

  def rules
    Yavalath
  end

  def test_info
    assert_equal('Yavalath', rules.name)
  end

  def test_players
    assert_equal([:white, :black], rules.new.players)
  end

  def test_init
    g = Game.new(rules)
    assert_equal(:white, g.turn)
    assert_equal(:hexagon, g.board.shape)
    assert_equal(5, g.board.length)
    assert_equal(4, g.board.window_size)
    assert_equal([], g.board.threats)
  end

  def test_game01
    # Simple uncontested 4-in-a-row
    g = play_sequence [:f5, :g5, :d5, :i6, :c5, :f7, :e5]

    assert(!g.draw?)
    assert(g.winner?(:white))
    assert(!g.loser?(:white))
    assert(!g.winner?(:black))
    assert(g.loser?(:black))
  end

  def test_game02
    # Simple unforced 3-in-a-row
    g = play_sequence [:f5, :g5, :d5, :i6, :e5]

    assert(!g.draw?)
    assert(!g.winner?(:white))
    assert(g.loser?(:white))
    assert(g.winner?(:black))
    assert(!g.loser?(:black))
  end

  def test_game03
    # Forced to block
    g = play_sequence [:f5, :f6, :d5, :g7, :c5, :e5]

    assert(!g.draw?)
    assert(g.winner?(:white))
    assert(!g.loser?(:white))
    assert(!g.winner?(:black))
    assert(g.loser?(:black))
  end

  def test_game04
    # Simultaneous 3/4 in-a-row
    g = play_sequence [:f5, :f6, :d5, :g7, :c5, :e5]

    assert(!g.draw?)
    assert(g.winner?(:white))
    assert(!g.loser?(:white))
    assert(!g.winner?(:black))
    assert(g.loser?(:black))
  end

end
