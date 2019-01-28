# frozen_string_literal: true

require_relative '../../test_helper'

class TestAttangleNotation < Minitest::Test
  include Vying

  def test_name
    assert_equal(:attangle_notation, AttangleNotation.notation_name)
  end

  def test_find
    assert_equal(AttangleNotation, Notation.find(:attangle_notation))
  end

  def test_to_move
    g = Game.new(Attangle)
    n = AttangleNotation.new(g)

    assert_equal('a1', n.to_move('a1'))
    assert_equal('e2', n.to_move('e1'))
    assert_equal('e4c6c2', n.to_move('e3,c6-c2'))
    assert_equal('e4c6c2', n.to_move('e3c6c2'))

    assert_equal('undo', n.to_move('undo'))
  end

  def test_translate
    g = Game.new(Attangle)
    n = AttangleNotation.new(g)

    assert_equal('a1', n.translate('a1', :white))
    assert_equal('e1', n.translate('e2', :white))
    assert_equal('e3,c6-c2', n.translate('e4c6c2', :white))

    assert_equal('undo', n.translate('undo', :black))
    assert_equal('undo', n.translate('undo', :white))
  end
end
