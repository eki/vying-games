require 'test/unit'

require 'vying'
require 'vying/rules/rules_test'

class TestYinsh < Test::Unit::TestCase
  include RulesTests

  def rules
    Yinsh
  end

  def test_info
    assert_equal( "Yinsh", rules.name )
  end

  def test_players
    assert_equal( [:white,:black], rules.players )
    assert_equal( [:white,:black], rules.new.players )
  end

  def test_initialize       # Need to be more thorough here
    g = Game.new( Yinsh )
    assert_equal( :white, g.turn )
  end

  def test_has_moves
    g = Game.new( Yinsh )
    assert_equal( [:white], g.has_moves )
    g << g.moves.first
    assert_equal( [:black], g.has_moves )
  end

  def test_moves
    g = Game.new( Yinsh )
    moves = g.moves

    YinshBoard::OMIT_COORDS.each do |c|
      assert( ! moves.include?( c.to_s ) )
    end
  end

  def test_rows
    g = Game.new( Yinsh )
    g << ["e7", "e9", 
          "e6", "f9", 
          "e5", "g9", 
          "e4", "h9",
          "e3", "i9"]

    g << ["e7f7", "e9e10", 
          "e6f6", "f9f10", 
          "e5f5", "g9g10", 
          "e4f4", "h9h10",
          "e3f3"]

    assert_equal( :white, g.turn )
    assert( g.rows.length == 1 )
    assert_equal( g.board.occupied[:white].sort, g.rows.first.sort )

    g << ["e7", "e6", "e5", "e4", "e3"]

    assert_equal( :white, g.turn )
    assert( ! g.rows.empty? )

    g << "f5"

    assert( g.rows.empty? )
    assert( g.removed_markers.empty? )

    assert_equal( :black, g.turn )
    assert_equal( 4, g.board.occupied[:WHITE_RING].length )
    assert( g.board[:f5].nil? )
    assert_equal( 1, g.score( :white ) )
  end

  def test_overline
    g = Game.new( Yinsh )

    g << ["e7", "e9", 
          "e6", "f9", 
          "e5", "g9", 
          "e4", "h9",
          "e2", "j9"]

    g << ["e7f7", "e9e10", 
          "e6f6", "f9f10", 
          "e5f5", "g9g10", 
          "e4f4", "h9h10",
          "e2e3", "j9i9",
          "e3f3"]
 
    assert_equal( :white, g.turn )
    assert( g.rows.length == 1 )
    assert_equal( g.board.occupied[:white].sort, g.rows.first.sort )

    g << "e7"

    assert( ! g.rows.first.include?( Coord[:e2] ) )

    g << ["e6", "e5", "e4", "e3"]

    assert_equal( :white, g.turn )
    assert( ! g.rows.empty? )

    g << "f5"

    assert( g.rows.empty? )
    assert( g.removed_markers.empty? )

    assert_equal( :black, g.turn )
    assert_equal( 4, g.board.occupied[:WHITE_RING].length )
    assert( g.board[:f5].nil? )
    assert_equal( 1, g.score( :white ) )
  end

  def test_two_rows
    g = Game.new( Yinsh )
    b = g.board

    b[:c1, :c2, :c4, :c5] = :white
    b[:c3] = :WHITE_RING

    b[:e2, :g4, :h5, :i6] = :white
    b[:f3] = :black

    b[:b7, :c8, :d9] = :WHITE_RING
    b[:f10, :g10, :h10, :i10, :j10] = :BLACK_RING

    g.removed[:WHITE_RING] = 1

    assert_equal( :white, g.turn )
    assert( g.moves.include?( "c3g3" ) )

    g << "c3g3"

    assert_equal( :white, g.turn )
    assert_equal( 2, g.rows.length )

    g << ["c1", "c2", "c3", "c4", "c5"]

    assert_equal( :white, g.turn )
    assert_equal( 2, g.rows.length )
    assert_equal( ["b7", "c8", "d9", "g3"].sort, g.moves.sort )

    g << "b7"

    assert_equal( :white, g.turn )
    assert_equal( 1, g.rows.length )

    g << ["e2", "f3", "g4", "h5", "i6"]
    
    assert_equal( :white, g.turn )
    assert_equal( 1, g.rows.length )
    assert_equal( ["c8", "d9", "g3"].sort, g.moves.sort )

    g << "c8"

    assert( g.final? )
    assert( g.winner?( :white ) )
    assert( g.loser?( :black ) )
    assert( ! g.winner?( :black ) )
    assert( ! g.loser?( :white ) )
    assert( ! g.draw? )
    assert_equal( 3, g.score( :white ) )
  end

  def test_two_rows_butted
    g = Game.new( Yinsh )
    b = g.board

    b[:c1, :c2, :c4, :c5] = :white
    b[:c3] = :WHITE_RING

    b[:d2, :f4, :g5, :h6] = :white
    b[:e3] = :black

    b[:b7, :c8, :d9] = :WHITE_RING
    b[:f10, :g10, :h10, :i10, :j10] = :BLACK_RING

    g.removed[:WHITE_RING] = 1

    assert_equal( :white, g.turn )
    assert( g.moves.include?( "c3f3" ) )

    g << "c3f3"

    assert_equal( :white, g.turn )
    assert_equal( 2, g.rows.length )
    assert( 1, g.rows.select { |row| row.include?( Coord[:c1] ) } )

    g << ["c1", "c2", "c3", "c4", "c5"]

    assert_equal( :white, g.turn )
    assert_equal( 2, g.rows.length )
    assert_equal( ["b7", "c8", "d9", "f3"].sort, g.moves.sort )

    g << "b7"

    assert_equal( :white, g.turn )
    assert_equal( 1, g.rows.length )

    g << ["d2", "e3", "f4", "g5", "h6"]
    
    assert_equal( :white, g.turn )
    assert_equal( 1, g.rows.length )
    assert_equal( ["c8", "d9", "f3"].sort, g.moves.sort )

    g << "c8"

    assert( g.final? )
    assert( g.winner?( :white ) )
    assert( g.loser?( :black ) )
    assert( ! g.winner?( :black ) )
    assert( ! g.loser?( :white ) )
    assert( ! g.draw? )
    assert_equal( 3, g.score( :white ) )
  end

end


