require_relative '../../../../test_helper'

class TestLinesOfAction < Minitest::Test
  include RulesTests

  def rules
    LinesOfAction
  end

  def test_info
    assert_equal( "Lines of Action", rules.name )
  end

  def test_players
    assert_equal( [:black,:white], rules.new.players )
  end

  def test_initialize       # Need to be more thorough here
    g = Game.new( rules )
    assert_equal( :black, g.turn )
    assert_equal( 12, g.board.count( :white ) )
    assert_equal( 12, g.board.count( :black ) )
  end

  def test_has_moves
    g = Game.new( rules )
    assert_equal( [:black], g.has_moves )
    g << g.moves.first
    assert_equal( [:white], g.has_moves )
    g << g.moves.first
    assert_equal( [:black], g.has_moves )
    g << g.moves.first
    assert_equal( [:white], g.has_moves )
    g << g.moves.first
    assert_equal( [:black], g.has_moves )
  end

  def test_moves
    g = Game.new( rules )

    assert_equal( 6, g.count( Coord[:a2], :n ) )
    assert_equal( 2, g.count( Coord[:a2], :e ) )
    assert_equal( 2, g.count( Coord[:a2], :se ) )

    g << "a2c2"

    assert_equal( 5, g.count( Coord[:a2], :n ) )
    assert_equal( 2, g.count( Coord[:a2], :e ) )
    assert_equal( 1, g.count( Coord[:a2], :se ) )

    assert_equal( 3, g.count( Coord[:c2], :n ) )
    assert_equal( 2, g.count( Coord[:c2], :e ) )
    assert_equal( 3, g.count( Coord[:c2], :se ) )

    g << "c1a3"

    assert_equal( 5, g.count( Coord[:a3], :n ) )
    assert_equal( 2, g.count( Coord[:a3], :e ) )
    assert_equal( 1, g.count( Coord[:a3], :ne ) )

    assert_equal( 5, g.count( Coord[:c1], :e ) )

    assert_equal( 12, g.board.count( :white ) )
    assert_equal( 11, g.board.count( :black ) )
  end

  def test_final
    g = play_sequence( ["a2c4", "e8e6", "h6e6", "g1a1", "h7f5", "f8d6", 
                        "h2e5", "c1a3", "a4d4", "e1e4", "a7c5", "b1b3", 
                        "a6d6", "b3b5", "a5c7", "d8h8", "h3d7", "a3a5", 
                        "h5b5", "e4d5", "h4e4"] )

    assert( !g.draw? )
    assert( g.winner?( :black ) )
    assert( !g.loser?( :black ) )
    assert( !g.winner?( :white ) )
    assert( g.loser?( :white ) )
  end

  def test_simultaneous_connection
    g = Game.new( rules )

    g.board.clear
    g.board[:a1,:a2,:e1] = :black
    g.board[:b1,:h8,:g7,:g6,:f5,:e4] = :white
    g.counts.clear
    g.history.last.send( :init_counts )

    assert( ! g.final? )
    assert( g.moves.include?( "e1b1" ) )

    g << "e1b1"

    assert( g.board.coords.connected?( g.board.occupied( :black ) ) )
    assert( g.board.coords.connected?( g.board.occupied( :white ) ) )

    assert_equal( :white, g.history.last.turn )

    assert( g.final? )

    assert( ! g.winner?( :black ) )
    assert( ! g.winner?( :white ) )

    assert( ! g.loser?( :white ) )
    assert( ! g.loser?( :black ) )

    assert( g.draw? )
  end

end

