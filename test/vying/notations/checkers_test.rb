# frozen_string_literal: true

require_relative '../../test_helper'

class TestCheckersNotation < Minitest::Test
  include Vying

  def test_name
    assert_equal(:checkers_notation, CheckersNotation.notation_name)
  end

  def test_find
    assert_equal(CheckersNotation, Notation.find(:checkers_notation))
  end

  def test_to_move
    g = Game.new AmericanCheckers
    n = CheckersNotation.new(g)

    assert_equal('b1c2', n.to_move('1-6'))
    assert_equal('a8b7', n.to_move('29-25'))
    assert_equal('f3e2', n.to_move('11-7'))

    assert_equal('undo', n.to_move('undo'))
  end

  def test_translate
    g = Game.new AmericanCheckers
    n = CheckersNotation.new(g)

    assert_equal('1-6', n.translate('b1c2', :red))
    assert_equal('1-6', n.translate('b1c2', :white))

    assert_equal('29-25', n.translate('a8b7', :red))
    assert_equal('29-25', n.translate('a8b7', :white))

    assert_equal('11-7', n.translate('f3e2', :red))
    assert_equal('11-7', n.translate('f3e2', :white))

    assert_equal('undo', n.translate('undo', :red))
    assert_equal('undo', n.translate('undo', :white))
  end

  def test_moves
    g = Game.new AmericanCheckers
    n = CheckersNotation.new(g)

    s = %w(9-14 9-13 10-15 10-14 11-16 11-15 12-16)

    assert_equal(s, n.moves)
    assert_equal(s, n.moves(:red))
    assert_equal([], n.moves(:white))
  end
end
