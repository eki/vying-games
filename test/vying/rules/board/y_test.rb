require 'test/unit'

require 'vying'
require 'vying/rules/rules_test'

class TestY < Test::Unit::TestCase
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
    assert_equal( 12, Y.options[:board_size] )

    assert_equal( 12, Y.new.board.width )
    assert_equal( 12, Y.new( :board_size => 12 ).board.width )
    assert_equal( 13, Y.new( :board_size => 13 ).board.width )
    assert_equal( 14, Y.new( :board_size => 14 ).board.width )

    assert_raise( RuntimeError ) { Y.new( :board_size => 11 ) }
    assert_raise( RuntimeError ) { Y.new( :board_size => 15 ) }
  end

  def test_has_moves
    g = Game.new( rules )
    assert_equal( [:blue], g.has_moves )
    g << g.moves.first
    assert_equal( [:red], g.has_moves )
  end

  def test_groups
    g = Game.new( rules )

    g << "b1"
    
    assert_equal( 1, g.groups[:blue].length )
    assert_equal( 0, g.groups[:red].length )

    assert_equal( 1, g.groups[:blue].first.sides )

    g << "a1"

    assert_equal( 1, g.groups[:blue].length )
    assert_equal( 1, g.groups[:red].length )

    assert_equal( 2, g.groups[:red].first.sides )

    g << "b3"
    
    assert_equal( 2, g.groups[:blue].length )
    assert_equal( 1, g.groups[:red].length )

    g << "a2"

    assert_equal( 2, g.groups[:blue].length )
    assert_equal( 1, g.groups[:red].length )

    g << "c2" << "a3"

    assert_equal( 2, g.groups[:blue].length )
    assert_equal( 1, g.groups[:red].length )

    g << "b2"

    assert_equal( 1, g.groups[:blue].length )
    assert_equal( 1, g.groups[:red].length )

    cs = [:b1, :b2, :b3, :c2].map { |c| Coord[c] }.sort

    assert_equal( cs, g.groups[:blue].first.coords.sort )
  end

  def test_sides12
    g = Game.new( rules )
    g << ["a9", "a4", 
          "b9", "b3",
          "c9", "c2",
          "d9"]

    assert_equal( 1, g.groups[:blue].length )
    assert_equal( 1, g.groups[:red].length )

    assert_equal( 2, g.groups[:blue].first.sides )
    assert_equal( 1, g.groups[:red].first.sides )

    g << "d1"

    assert_equal( 2, g.groups[:red].first.sides )

    g << ["e8", "f7",
          "e7", "g6",
          "e6", "h5",
          "e5", "i4",
          "e4", "j3",
          "e3", "k2",
          "e2", "l1"]

    assert_equal( 2, g.groups[:blue].first.sides )
    assert_equal( 2, g.groups[:red].length )
    assert_equal( [2,2],  g.groups[:red].map { |group| group.sides } )

    assert( ! g.final? )

    g << "f1"

    assert_equal( 3, g.groups[:blue].first.sides )
    assert( g.groups[:blue].first.winning? )
    assert( g.final? )
    assert( g.winner?( :blue ) )
    assert( g.loser?( :red ) )
    assert( ! g.winner?( :red ) )
    assert( ! g.loser?( :blue ) )
  end

  def test_sides14
    g = Game.new( rules, :board_size => 14 )
    g << ["a9", "a6", 
          "b9", "b5",
          "c9", "c4",
          "d9", "d3",
          "e9", "e2",
          "f9",]

    assert_equal( 1, g.groups[:blue].length )
    assert_equal( 1, g.groups[:red].length )

    assert_equal( 2, g.groups[:blue].first.sides )
    assert_equal( 1, g.groups[:red].first.sides )

    g << "f1"

    assert_equal( 2, g.groups[:red].first.sides )

    g << ["f8", "h7",
          "f7", "i6",
          "f6", "j5",
          "f5", "k4",
          "f4", "l3",
          "f3", "m2",
          "f2", "n1"]

    assert_equal( 2, g.groups[:blue].first.sides )
    assert_equal( 2, g.groups[:red].length )
    assert_equal( [2,2],  g.groups[:red].map { |group| group.sides } )

    assert( ! g.final? )

    g << "g1"

    assert_equal( 3, g.groups[:blue].first.sides )
    assert( g.groups[:blue].first.winning? )
    assert( g.final? )
    assert( g.winner?( :blue ) )
    assert( g.loser?( :red ) )
    assert( ! g.winner?( :red ) )
    assert( ! g.loser?( :blue ) )
  end
end

