# frozen_string_literal: true

require_relative '../../../test_helper'

class TestAccasta < Minitest::Test
  include RulesTests

  def rules
    Accasta
  end

  def test_info
    assert_equal('Accasta', rules.name)
    assert(rules.version == '0.1.0')
    assert(rules.highest_score_determines_winner?)
  end

  def test_players
    assert_equal([:white, :black], rules.new.players)
  end

  def test_initialize
    g = Game.new(rules)

    assert_equal(2 * 9, g.board.occupied.length)
    assert_equal(:white, g.turn)
  end

  def test_options
    assert_equal(:standard, rules.options[:variant].default)
    assert_equal([:standard, :pari], rules.options[:variant].values)
  end

  def test_has_moves
    g = Game.new(rules)
    assert_equal([:white], g.has_moves)
    g << '3a1a4'
    assert_equal([:black], g.has_moves)
  end

  def test_play
    g = Game.new(rules)

    assert_equal(60, g.moves.length)

    assert_raises(RuntimeError) { g << '1a1b1' }
    assert_raises(RuntimeError) { g << '1d7a4' }
    assert_raises(RuntimeError) { g << '1c3a3' }

    g << '3a1a4'
    assert_equal([:black], g.has_moves)
    g << '1d7a4'
    assert_equal([:black], g.has_moves)
    assert_equal('d7', g.lastc.to_s)
    assert(g.moves.include?(:pass))
    assert_raises(RuntimeError) { g << '1d5c5' }
    g << '1d7b5'
    assert_equal([:black], g.has_moves)
    assert_equal('d7', g.lastc.to_s)
    assert(g.moves.include?(:pass))
    g << '1d7c6'
    assert_equal([:white], g.has_moves)
  end

end
