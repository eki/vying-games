# frozen_string_literal: true

require_relative '../test_helper'

class TestRules < Minitest::Test
  include Vying

  def test_find
    Rules.latest_versions.each do |r|
      assert_equal(r, Rules.find(r.to_snake_case))
      assert_equal(r, Rules.find(r.class_name))
      assert_equal(r, Rules.find(r.class_name.downcase))
    end

    assert_nil(Rules.find('foo_bar'))
  end

  def test_find_by_version
    skip('older "broken" versions have been removed, remove this test, too?')
    r = Rules.find(Kalah, '1.0.0')
    assert_equal('Kalah', r.class_name)
    assert_equal('1.0.0', r.version)

    r = Rules.find(Kalah, '2.0.0')
    assert_equal('Kalah', r.class_name)
    assert_equal('2.0.0', r.version)

    r = Rules.find(Kalah, 'blah blah blah')  # Ask for a version that doesn't
    assert_equal('Kalah', r.class_name)      # exist and you get the latest
    assert_equal(Rules.find(Kalah).version, r.version)
  end

  def test_sealed_moves
    assert(Footsteps.sealed_moves?)
    assert(!TicTacToe.sealed_moves?)
  end

  def test_invalid_options
    assert_raises(RuntimeError) do
      TicTacToe.new(board_size: 10)
    end

    assert_raises(RuntimeError) do
      TicTacToe.new(width: 10, height: 10)
    end

    assert_raises(RuntimeError) do
      Ataxx.new(width: 10, height: 10)
    end

    assert_raises(RuntimeError) do
      Ataxx.new(1234, width: 10, height: 10)
    end

    assert_raises(RuntimeError) do
      Kalah.new(seeds_per_cup: 3, width: 10, height: 10)
    end

    Kalah.new(seeds_per_cup: 3)

    assert_raises(RuntimeError) do
      Kalah.new(seeds_per_cup: 1)
    end
  end

  def test_cached
    assert(Othello.cached?(:moves)) # Oh so fragile... *sigh*
    assert(!Othello.cached?(:final?))
  end

  def test_inspect
    assert_equal("#<Rules name: 'Kalah', version: 2.0.0>",
      Rules.find(Kalah, '2.0.0').inspect)
  end

  def test_deterministic
    assert(Othello.deterministic?)
    assert(!Pig.deterministic?)
    assert(Ataxx.deterministic?)
  end
end
