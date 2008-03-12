require 'test/unit'

require 'vying'
require 'vying/rules/rules_test'

class TestCephalopod < Test::Unit::TestCase
  include RulesTests

  def rules
    Cephalopod
  end

  def test_info
    assert_equal( "Cephalopod", Cephalopod.info[:name] )
  end

  def test_players
    assert_equal( [:white,:black], Cephalopod.players )
    assert_equal( [:white,:black], Cephalopod.new.players )
  end

  def test_initialize
    g = Game.new( Cephalopod )
    assert_equal( :white, g.turn )
    assert_equal( 5, g.board.width )
    assert_equal( 5, g.board.height )
    assert_equal( 25, g.board.empty_count )
  end

  def test_has_moves
    g = Game.new( Cephalopod )
    assert_equal( [:white], g.has_moves )
    g << g.moves.first
    assert_equal( [:black], g.has_moves )
    g << g.moves.first
    assert_equal( [:white], g.has_moves )
  end

  def test_moves
    g = Game.new( Cephalopod )

    assert_equal( 25, g.moves.length )
    g.board.coords.each do |c|
      assert( g.move?( "#{c}", :white ) )
    end
  end

  def test_capture
    g = Game.new( Cephalopod )

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

  def test_illegal_captures
    g = Game.new Cephalopod

    g << ["b1", "d1", "c2", "c1", "b1", "c2", "c1", "c3", "d2", "b2", "c2",
          "b2", "c1", "d2", "c3", "c2", "e2", "d2", "e2", "d1"]

    assert(   g.move?( "d2" ) )
    assert( ! g.move?( "c2" ) )
  end


end

