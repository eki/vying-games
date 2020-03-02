# frozen_string_literal: true

require_relative '../../test_helper'

class TestMancalaNotation < Minitest::Test
  include Vying::Games

  def test_name
    assert_equal(:mancala_notation, MancalaNotation.notation_name)
  end

  def test_find
    assert_equal(MancalaNotation, Notation.find(:mancala_notation))
  end

  def test_to_move
    g = Game.new Kalah
    n = MancalaNotation.new(g)

    assert_equal('e1', n.to_move('B'))
    assert_equal('f2', n.to_move('f'))
    assert_equal('b1', n.to_move('E'))

    assert_equal('undo', n.to_move('undo'))
  end

  def test_translate
    g = Game.new Kalah
    n = MancalaNotation.new(g)

    assert_equal('A', n.translate('f1', :one))
    assert_equal('A', n.translate('f1', :two))
    assert_equal('a', n.translate('a2', :one))
    assert_equal('a', n.translate('a2', :two))
    assert_equal('C', n.translate('d1', :one))
    assert_equal('C', n.translate('d1', :two))
    assert_equal('d', n.translate('d2', :one))
    assert_equal('d', n.translate('d2', :two))

    assert_equal('undo', n.translate('undo', :one))
    assert_equal('undo', n.translate('undo', :two))
  end

  def test_moves
    g = Game.new Kalah
    n = MancalaNotation.new(g)

    assert_equal(:one, g.turn)

    assert_equal(%w(A B C D E F), n.moves.sort)
    assert_equal(%w(A B C D E F), n.moves(:one).sort)
    assert_equal([], n.moves(:two))

    g << 'c1'

    assert_equal(:two, g.turn)

    assert_equal(%w(a b c d e f), n.moves.sort)
    assert_equal(%w(a b c d e f), n.moves(:two).sort)
    assert_equal([], n.moves(:one))
  end
end
