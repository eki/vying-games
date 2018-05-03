
# frozen_string_literal: true

require_relative '../../test_helper'

class TestAbandeNotation < Minitest::Test
  include Vying

  def test_name
    assert_equal(:abande_notation, AbandeNotation.notation_name)
  end

  def test_find
    assert_equal(AbandeNotation, Notation.find(:abande_notation))
  end

  def test_to_move
    g = Game.new(Abande)
    n = AbandeNotation.new(g)

    assert_equal('a1', n.to_move('a1'))
    assert_equal('e2', n.to_move('e1'))
    assert_equal('e4d3', n.to_move('e3-d3'))
    assert_equal('e4d3', n.to_move('e3d3'))

    assert_equal('pass', n.to_move('pass'))
    assert_equal('undo', n.to_move('undo'))
  end

  def test_translate
    g = Game.new(Abande)
    n = AbandeNotation.new(g)

    assert_equal('a1', n.translate('a1', :white))
    assert_equal('e1', n.translate('e2', :white))
    assert_equal('e3-d3', n.translate('e4d3', :white))

    assert_equal('pass', n.translate('pass', :black))
    assert_equal('pass', n.translate('pass', :white))
    assert_equal('undo', n.translate('undo', :black))
    assert_equal('undo', n.translate('undo', :white))
  end
end
