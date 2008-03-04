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
      assert( g.move?( "1#{c}", :white ) )
    end
  end

  def test_capture
    g = Game.new( Cephalopod )

    g << "1b1" << "1d1"

    assert(   g.move?( "2c1" ) )
    assert( ! g.move?( "1c1" ) )

    g << "2c1"

    assert_equal( ["b1", "d1"].sort, g.moves.sort )

    g << "d1"

    assert_equal( ["b1"], g.moves )

    g << "b1"

    assert_equal( 24, g.moves.length )

    g << "1c3" << "1b2" << "1d2"

    assert( g.move?( "2c2" ) )
    assert( g.move?( "3c2" ) )
    assert( g.move?( "4c2" ) )
    assert( g.move?( "5c2" ) )

    g << "2c2"

    assert( ! g.move?( "c1" ) )
    assert_equal( ["c3", "b2", "d2"].sort, g.moves.sort )

    g << "c3"

    assert( ! g.move?( "c1" ) )
    assert_equal( ["b2", "d2"].sort, g.moves.sort )

    g << "d2"

    assert( ! g.move?( "c1" ) )
    assert( ! g.move?( "b2" ) )
    assert( ! g.move?( "d2" ) )

  end


end

