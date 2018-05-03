require_relative '../../../test_helper'

class TestCephalopod < Minitest::Test
  include RulesTests

  def rules
    Cephalopod
  end

  def test_info
    assert_equal( "Cephalopod", rules.name )
  end

  def test_players
    assert_equal( [:white,:black], rules.new.players )
  end

  def test_initialize
    g = Game.new( rules )
    assert_equal( :white, g.turn )
    assert_equal( 5, g.board.width )
    assert_equal( 5, g.board.height )
    assert_equal( 25, g.board.empty_count )
  end

  def test_has_moves
    g = Game.new( rules )
    assert_equal( [:white], g.has_moves )
    g << g.moves.first
    assert_equal( [:black], g.has_moves )
    g << g.moves.first
    assert_equal( [:white], g.has_moves )
  end

  def test_moves
    g = Game.new( rules )

    assert_equal( 25, g.moves.length )
    g.board.coords.each do |c|
      assert( g.move?( "#{c}", :white ) )
    end
  end

  def test_capture
    g = Game.new( rules )

    g << "b1" << "d1"

    assert(   g.move?( "c1" ) )

    g << "c1"

    assert_equal( ["b1", "d1"].sort, g.moves.sort )

    g << "d1"

    assert_equal( ["b1"], g.moves )

    g << "b1"

    assert_equal( ["c1"], g.moves )

    g << "c1"

    assert_equal( 24, g.moves.length )

    g << "c3" << "b2" << "d2"

    assert( g.move?( "c2" ) )

    g << "c2"

    assert_equal( ["c3", "b2", "d2", "c1"].sort, g.moves.sort )

    g << "c3"

    assert_equal( ["b2", "d2", "c1"].sort, g.moves.sort )

    g << "d2"

    assert( g.move?( "c2" ) )

    g << "c2"

    assert_equal( 22, g.moves.length )
    assert_equal( 2, g.board[:c2].up )
  end

  def test_illegal_captures_01
    g = Game.new( rules ) 

    g << ["b1", "d1", "c2", "c1", "b1", "c2", "c1", "c3", "d2", "b2", "c2",
          "b2", "c1", "d2", "c3", "c2", "e2", "d2", "e2", "d1"]

    assert(   g.move?( "d2" ) )
    assert( ! g.move?( "c2" ) )
  end

  def test_illegal_captures_02
    g = Game.new( rules ) 
    g << ["a1", "a2", "e2", "b3", "d2", "b2", "b3", "a2", "b2", "b1", "a1",
          "b2", "b1", "e4", "c2", "a2", "e3", "e2", "e4", "e3", "b2", "a2",
          "b1", "c2", "b2", "c4", "b5", "a3", "b4", "b5", "c4", "b4", "d1",
          "c1", "b5", "d4", "b3", "b2", "a3", "b3", "a5", "a1", "a3", "c2",
          "c1", "d2", "c2", "e4", "d4", "e3", "e4", "e3", "d2", "c2", "d1", 
          "d2", "e1", "d1", "d2", "e1", "d1", "d4", "a4", "b4", "a5", "a4", 
          "b4", "b5", "a4", "b4", "a2", "a1", "a3", "a2", "b2", "a3", "c3", 
          "b1", "c4", "d4", "b4", "c4", "c1", "b1", "d1", "c1", "d4", "c5", 
          "b4", "b5", "b4", "c5", "b5", "d5", "e5", "d5", "e4", "e5", "a4", 
          "a1", "d1", "c2", "c1", "b2", "c2", "d5", "d4", "e5", "d5", "e4", 
          "e5", "e4", "d5", "e5", "c1", "e1", "b2", "d2", "d3", "e3", "d2",
          "c3", "d3", "e4", "c5", "c3", "a5", "b5", "a4", "a5", "b5", "a5", 
          "c5", "b5", "d5", "a4", "e2", "d2", "d1", "e2", "d3", "d2", "c5",
          "c4"]

    assert(   g.move?( "d5" ) )
    assert( ! g.move?( "b5" ) )
  end
end

