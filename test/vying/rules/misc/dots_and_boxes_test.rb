require 'test/unit'

require 'vying'
require 'vying/rules/rules_test'

class TestDotsAndBoxes < Test::Unit::TestCase
  include RulesTests

  def rules
    DotsAndBoxes
  end

  def test_info
    assert_equal( "Dots and Boxes", rules.info[:name] )
  end

  def test_players
    assert_equal( [:black, :white], rules.players )
    assert_equal( [:black, :white], rules.new.players )
  end

  def test_initialize
    p = rules.new

    assert_equal( DotsAndBoxes::Grid.new, p.grid )
    assert_equal( 6, p.grid.width )
    assert_equal( 6, p.grid.height )
    assert_equal( 60, p.grid.lines.keys.length )
    assert_equal( 25, p.grid.boxes.keys.length )
    assert_equal( 0, p.grid.lines.select { |k,v| v }.length )
    assert_equal( 0, p.grid.boxes.select { |k,v| v }.length )
  end

  def test_moves
    g = Game.new rules

    assert_equal( :black, g.turn )
    assert_equal( 60, g.moves.length )

    g.grid.lines.keys.each do |k|
      g.move?( "#{k.first}:#{k.last}" )
    end

    g << "9:10" << "9:15" << "15:16" << "10:16"

    assert_equal( :white, g.grid[9, 10, 15, 16] )
    assert_equal( :white, g.turn )

    g << "1:2"

    assert_equal( :black, g.turn )
  end

end

