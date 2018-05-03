require_relative '../../../../test_helper'

class TestY < Minitest::Test
  include RulesTests

  def rules
    Y
  end

  def test_info
    assert_equal( "Y", rules.name )
  end

  def test_players
    assert_equal( [:blue,:red], rules.new.players )
  end

  def test_initialize       # Need to be more thorough here
    g = Game.new( rules )
    assert_equal( :blue, g.turn )
  end

  def test_options
    assert_equal( 12, Y.options[:board_size].default )
    assert_equal( [12,13,14], Y.options[:board_size].values )

    assert_equal( 12, Y.new.board.width )
    assert_equal( 12, Y.new( :board_size => 12 ).board.width )
    assert_equal( 13, Y.new( :board_size => 13 ).board.width )
    assert_equal( 14, Y.new( :board_size => 14 ).board.width )

    assert_raises( RuntimeError ) { Y.new( :board_size => 11 ) }
    assert_raises( RuntimeError ) { Y.new( :board_size => 15 ) }
  end

  def test_has_moves
    g = Game.new( rules )
    assert_equal( [:blue], g.has_moves )
    g << g.moves.first
    assert_equal( [:red], g.has_moves )
  end

  def test_sides12
    g = Game.new( rules )
    g << ["a9", "a4", 
          "b9", "b3",
          "c9", "c2",
          "d9"]

    assert_equal( 1, g.board.groups[:blue].length )
    assert_equal( 1, g.board.groups[:red].length )

    g << "d1"

    g << ["e8", "f7",
          "e7", "g6",
          "e6", "h5",
          "e5", "i4",
          "e4", "j3",
          "e3", "k2",
          "e2", "l1"]

    assert_equal( 2, g.board.groups[:red].length )

    assert( ! g.final? )

    g << "f1"

    assert( g.final? )
    assert( g.winner?( :blue ) )
    assert( g.loser?( :red ) )
    assert( ! g.winner?( :red ) )
    assert( ! g.loser?( :blue ) )
    assert( ! g.draw? )
  end

  def test_sides14
    g = Game.new( rules, :board_size => 14 )
    g << ["a9", "a6", 
          "b9", "b5",
          "c9", "c4",
          "d9", "d3",
          "e9", "e2",
          "f9",]

    assert_equal( 1, g.board.groups[:blue].length )
    assert_equal( 1, g.board.groups[:red].length )

    g << "f1"

    g << ["f8", "h7",
          "f7", "i6",
          "f6", "j5",
          "f5", "k4",
          "f4", "l3",
          "f3", "m2",
          "f2", "n1"]

    assert_equal( 2, g.board.groups[:red].length )

    assert( ! g.final? )

    g << "g1"

    assert( g.final? )
    assert( g.winner?( :blue ) )
    assert( g.loser?( :red ) )
    assert( ! g.winner?( :red ) )
    assert( ! g.loser?( :blue ) )
    assert( ! g.draw? )
  end
end

