# frozen_string_literal: true

require_relative '../../../test_helper'

class TestBreakthrough < Minitest::Test
  include RulesTests

  def rules
    Breakthrough
  end

  def test_info
    assert_equal('Breakthrough', rules.name)
  end

  def test_players
    assert_equal([:black, :white], rules.new.players)
  end

  def test_init
    g = Game.new(rules)

    b = Board.square(8)
    b[:a1, :b1, :c1, :d1, :e1, :f1, :g1, :h1,
      :a2, :b2, :c2, :d2, :e2, :f2, :g2, :h2] = :black

    b[:a7, :b7, :c7, :d7, :e7, :f7, :g7, :h7,
      :a8, :b8, :c8, :d8, :e8, :f8, :g8, :h8] = :white

    assert_equal(b, g.board)

    assert_equal(:black, g.turn)
  end

  def test_has_score
    g = Game.new(rules)
    assert(g.has_score?)
  end

  def test_has_moves
    g = Game.new(rules)
    assert_equal([:black], g.has_moves)
    g << g.moves.first
    assert_equal([:white], g.has_moves)
  end

  def test_moves
    g = Game.new(rules)

    assert_equal(%w(a2a3 a2b3 b2b3 b2c3 b2a3 c2c3 c2d3
                   c2b3 d2d3 d2e3 d2c3 e2e3 e2f3 e2d3
                   f2f3 f2g3 f2e3 g2g3 g2h3 g2f3 h2h3
                   h2g3).sort, g.moves.map(&:to_s).sort)

    g << g.moves.first until g.final?

    refute_equal(g.history.first, g.history.last)
  end

  def test_move_forward
    g = Game.new(rules)

    # Clear out the board
    g.board[:a1, :b1, :c1, :d1, :e1, :f1, :g1, :h1,
            :a2, :b2, :c2, :d2, :e2, :f2, :g2, :h2,
            :a7, :b7, :c7, :d7, :e7, :f7, :g7, :h7,
            :a8, :b8, :c8, :d8, :e8, :f8, :g8, :h8] = nil

    g.board[:e4] = :black
    g.clear_cache
    assert_equal(%w(e4e5 e4f5 e4d5), g.moves.map(&:to_s))

    g.board[:e5] = :white
    g.clear_cache
    assert_equal(%w(e4f5 e4d5), g.moves.map(&:to_s))

    g.board[:e5] = :black
    g.clear_cache
    assert_equal(%w(e4f5 e4d5 e5e6 e5f6 e5d6),
                  g.moves.map(&:to_s))

    g.board[:e5] = nil
    g.clear_cache
    assert_equal(%w(e4e5 e4f5 e4d5), g.moves.map(&:to_s))

    g << 'e4e5'

    assert_nil(g.board[:e4])
    assert_equal(:black, g.board[:e5])

    g.board[:e4] = :black
    g.board[:e5] = :white
    g.rotate_turn until g.turn == :white
    g.clear_cache

    refute_equal(['e5e4'], g.moves.map(&:to_s))

    g.board[:e4] = nil
    g.clear_cache
    assert_equal(%w(e5e4 e5f4 e5d4), g.moves.map(&:to_s))

    g.board[:e4] = :white
    g.clear_cache
    assert_equal(%w(e5f4 e5d4 e4e3 e4f3 e4d3),
                  g.moves.map(&:to_s))

    g.board[:e4] = nil
    g.clear_cache

    g << 'e5e4'

    assert_nil(g.board[:e5])
    assert_equal(:white, g.board[:e4])
  end

  def test_capture
    g = Game.new(rules)

    # Clear out the board
    g.board[:a1, :b1, :c1, :d1, :e1, :f1, :g1, :h1,
            :a2, :b2, :c2, :d2, :e2, :f2, :g2, :h2,
            :a7, :b7, :c7, :d7, :e7, :f7, :g7, :h7,
            :a8, :b8, :c8, :d8, :e8, :f8, :g8, :h8] = nil

    g.board[:a2, :b2, :c2] = :black
    g.board[:b3] = :white
    g.clear_cache

    assert_equal(%w(a2a3 a2b3 b2c3 b2a3
                   c2c3 c2d3 c2b3), g.moves.map(&:to_s))

    g.rotate_turn
    g.clear_cache

    assert_equal(%w(b3c2 b3a2), g.moves.map(&:to_s))

    g << 'b3c2'

    assert_nil(g.board[:b3])
    assert_equal(:white, g.board[:c2])
  end

  def test_pass
    g = Game.new(rules)

    # Clear out the board
    g.board[:a1, :b1, :c1, :d1, :e1, :f1, :g1, :h1,
            :a2, :b2, :c2, :d2, :e2, :f2, :g2, :h2,
            :a7, :b7, :c7, :d7, :e7, :f7, :g7, :h7,
            :a8, :b8, :c8, :d8, :e8, :f8, :g8, :h8] = nil

    g.board[:a2, :b2, :c2] = :black

    g << g.moves.first until g.final?

    assert(!g.draw?)
    assert(g.winner?(:black))
    assert(g.loser?(:white))
    assert(!g.winner?(:white))
    assert(!g.loser?(:black))
  end

  def test_game01
    # This game is going to be a win for Black
    g = play_sequence(%w(b2b3 c7c6 b3b4 c6c5 b4b5 c5c4
                        b5b6 c4c3 b6a7 c3d2 a7b8))

    assert(!g.draw?)
    assert(g.winner?(:black))
    assert(!g.loser?(:black))
    assert(!g.winner?(:white))
    assert(g.loser?(:white))
  end

  def test_game02
    # This game is going to be a win for White
    g = play_sequence(%w(b2b3 c7c6 b3b4 c6c5 b4b5 c5c4
                        b5b6 c4c3 b6a7 c3d2 a2a3 d2e1))

    assert(!g.draw?)
    assert(!g.winner?(:black))
    assert(g.loser?(:black))
    assert(g.winner?(:white))
    assert(!g.loser?(:white))
  end

end
