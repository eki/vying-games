# frozen_string_literal: true

require_relative '../../../test_helper'

class TestFootsteps_1_0_0 < Minitest::Test
  include RulesTests

  def rules
    Rules.find Footsteps, '1.0.0'
  end

  def test_info
    assert_equal('Footsteps', rules.name)
    assert(rules.sealed_moves?)
  end

  def test_players
    assert_equal([:left, :right], rules.new.players)
  end

  def test_init
    g = Game.new(rules)

    b = Board.rect(7, 1)
    b[:d1] = :white

    assert_equal(b, g.board)
  end

  def test_has_score
    g = Game.new(rules)
    assert(!g.has_score?)
  end

  def test_has_moves
    g = Game.new(rules)
    assert_equal([:left, :right], g.has_moves)
    assert(g.has_moves.include?(g.turn))
    g << 'left_1'
    assert_equal([:right], g.has_moves)
    assert(g.has_moves.include?(g.turn))
    g << 'right_1'
    assert_equal([:left, :right], g.has_moves)
    assert(g.has_moves.include?(g.turn))
    g << 'right_2'
    assert_equal([:left], g.has_moves)
    assert(g.has_moves.include?(g.turn))
  end

  def test_censor
    g = Game.new(rules)
    p = g.censor(:left)
    assert_nil(p.bids[:left])
    assert_nil(p.bids[:right])

    g << 'right_10'

    p = g.censor(:left)
    assert_nil(p.bids[:left])
    assert_equal(:hidden, p.bids[:right])

    p = g.censor(:right)
    assert_nil(p.bids[:left])
    assert_equal(10, p.bids[:right])

    g << 'left_5'

    p = g.censor(:left)
    assert_nil(p.bids[:left])
    assert_nil(p.bids[:right])

    p = g.censor(:right)
    assert_nil(p.bids[:left])
    assert_nil(p.bids[:right])

    g << 'left_4'

    p = g.censor(:left)
    assert_equal(4, p.bids[:left])
    assert_nil(p.bids[:right])

    p = g.censor(:right)
    assert_equal(:hidden, p.bids[:left])
    assert_nil(p.bids[:right])
  end

  def test_game01
    g = play_sequence([:left_50, :right_40,
                        :right_1, :right_1, :right_1, :right_1])

    assert(!g.draw?)
    assert(!g.winner?(:left))
    assert(g.loser?(:left))
    assert(g.winner?(:right))
    assert(!g.loser?(:right))
  end

  def test_game02
    g = play_sequence([:left_10, :right_9,
                        :right_8,  :left_9,
                         :left_2, :right_1])

    assert(!g.draw?)
    assert(g.winner?(:left))
    assert(!g.loser?(:left))
    assert(!g.winner?(:right))
    assert(g.loser?(:right))
  end

  def test_game03
    g = play_sequence([:left_10, :right_9,
                        :right_9,  :left_8,
                        :left_20, :right_20,
                        :right_10, :left_10,
                        :left_1, :right_1, :left_1, :right_1])

    assert(g.draw?)
    assert(!g.winner?(:left))
    assert(!g.loser?(:left))
    assert(!g.winner?(:right))
    assert(!g.loser?(:right))
  end

end
