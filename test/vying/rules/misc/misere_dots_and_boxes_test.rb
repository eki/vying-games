# frozen_string_literal: true

require_relative '../../../test_helper'

class TestMisereDotsAndBoxes < Minitest::Test
  include RulesTests

  def rules
    MisereDotsAndBoxes
  end

  def test_info
    assert_equal('Misere Dots and Boxes', rules.name)
    assert(rules.lowest_score_determines_winner?)
    assert(!rules.highest_score_determines_winner?)
  end

  def test_players
    assert_equal([:black, :white], rules.new.players)
  end

  def test_initialize
    p = rules.new

    assert_equal(Grid.new, p.grid)
    assert_equal(6, p.grid.width)
    assert_equal(6, p.grid.height)
    assert_equal(60, p.grid.lines.keys.length)
    assert_equal(25, p.grid.boxes.keys.length)
    assert_equal(0, p.grid.lines.select { |k, v| v }.length)
    assert_equal(0, p.grid.boxes.select { |k, v| v }.length)
  end

  def test_moves
    g = Game.new rules

    assert_equal(:black, g.turn)
    assert_equal(60, g.moves.length)

    g.grid.lines.each_key do |k|
      g.move?("#{k.first}:#{k.last}")
    end

    g << '9:10' << '9:15' << '15:16' << '10:16'

    assert_equal(:white, g.grid[9, 10, 15, 16])
    assert_equal(:white, g.turn)

    g << '1:2'

    assert_equal(:black, g.turn)
  end

end
