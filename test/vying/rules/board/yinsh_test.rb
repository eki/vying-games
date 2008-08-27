require 'test/unit'

require 'vying'
require 'vying/rules/rules_test'

class TestYinsh < Test::Unit::TestCase
  include RulesTests

  def rules
    Yinsh
  end

  def test_info
    assert_equal( "YINSH", rules.name )
  end

  def test_players
    assert_equal( [:white,:black], rules.new.players )
  end

  def test_initialize       # Need to be more thorough here
    g = Game.new( rules )
    assert_equal( :white, g.turn )
  end

  def test_has_moves
    g = Game.new( rules )
    assert_equal( [:white], g.has_moves )
    g << g.moves.first
    assert_equal( [:black], g.has_moves )
  end

  def test_moves
    g = Game.new( rules )
    moves = g.moves

    YinshBoard::OMIT_COORDS.each do |c|
      assert( ! moves.include?( c.to_s ) )
    end
  end

  def test_rows
    g = Game.new( rules )
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
    g = Game.new( rules )

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

    rows = [[:e2, :e3, :e4, :e5, :e6], 
            [:e3, :e4, :e5, :e6, :e7]].map { |r| r.map { |c| Coord[c] } }
 
    assert_equal( :white, g.turn )
    assert_equal( 2, g.rows.length )

    rows.each do |row|
      assert( g.rows.include?( row ) )
    end

    g << "e7"

    assert( ! g.moves.include?( "e2" ) )

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
    g = Game.new( rules )
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
    assert_equal( ["b7", "c8", "d9", "g3"].sort, 
                  g.moves.map { |m| m.to_s }.sort )

    g << "b7"

    assert_equal( :white, g.turn )
    assert_equal( 1, g.rows.length )

    g << ["e2", "f3", "g4", "h5", "i6"]
    
    assert_equal( :white, g.turn )
    assert_equal( 1, g.rows.length )
    assert_equal( ["c8", "d9", "g3"].sort,
                  g.moves.map { |m| m.to_s }.sort )

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
    g = Game.new( rules )
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
    assert_equal( 1, g.rows.select { |row| row.include?( Coord[:c1] ) }.length )

    g << ["c1", "c2", "c3", "c4", "c5"]

    assert_equal( :white, g.turn )
    assert_equal( 2, g.rows.length )
    assert_equal( ["b7", "c8", "d9", "f3"].sort,
                  g.moves.map { |m| m.to_s }.sort )

    g << "b7"

    assert_equal( :white, g.turn )
    assert_equal( 1, g.rows.length )

    g << ["d2", "e3", "f4", "g5", "h6"]
    
    assert_equal( :white, g.turn )
    assert_equal( 1, g.rows.length )
    assert_equal( ["c8", "d9", "f3"].sort,
                  g.moves.map { |m| m.to_s }.sort )

    g << "c8"

    assert( g.final? )
    assert( g.winner?( :white ) )
    assert( g.loser?( :black ) )
    assert( ! g.winner?( :black ) )
    assert( ! g.loser?( :white ) )
    assert( ! g.draw? )
    assert_equal( 3, g.score( :white ) )
  end

  def test_complete_opponent_row
    g = Game.new( rules )
    b = g.board

    b[:c1, :c2, :c4, :c5, :c6] = :black
    b[:c3] = :white
    b[:b3] = :WHITE_RING

    b[:b7, :c8, :d9, :e10] = :WHITE_RING
    b[:f10, :g10, :h10, :i10, :j10] = :BLACK_RING

    assert_equal( :white, g.turn )
    assert( g.moves.include?( "b3d3" ) )

    g << "b3d3"

    assert_equal( :black, g.turn )
    
    g << ["c1", "c2", "c3", "c4", "c5"]

    assert_equal( :black, g.turn )
    assert_equal( ["f10", "g10", "h10", "i10", "j10"].sort,
                  g.moves.map { |m| m.to_s }.sort )

    g << "f10"

    assert_equal( :black, g.turn )  # still black's turn because he only 
                                    # removed a row created by white
  end

  def test_complete_own_row_and_opponent_row
    g = Game.new( rules )
    b = g.board

    b[:c1, :c2, :c4, :c5, :c6] = :black
    b[:b1, :b2, :b4, :b5, :b6] = :white
    b[:c3] = :white
    b[:b3] = :WHITE_RING

    b[:b7, :c8, :d9, :e10] = :WHITE_RING
    b[:f10, :g10, :h10, :i10, :j10] = :BLACK_RING

    assert_equal( :white, g.turn )
    assert( g.moves.include?( "b3d3" ) )

    g << "b3d3"

    assert_equal( :white, g.turn )

    g << ["b1", "b2", "b3", "b4", "b5"]

    assert_equal( :white, g.turn )
    assert_equal( ["d3", "b7", "c8", "d9", "e10"].sort,
                  g.moves.map { |m| m.to_s }.sort )

    g << "d3"

    assert_equal( :black, g.turn )
    
    g << ["c1", "c2", "c3", "c4", "c5"]

    assert_equal( :black, g.turn )
    assert_equal( ["f10", "g10", "h10", "i10", "j10"].sort,
                  g.moves.map { |m| m.to_s }.sort )

    g << "f10"

    assert_equal( :black, g.turn )  # still black's turn because he only 
                                    # removed a row created by white
  end

  def test_two_overlines_butted
    g = Game.new( rules )
    b = g.board

    b[:c1, :c2, :c4, :c5, :c6] = :white
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
    assert_equal( 4, g.rows.length )
    assert_equal( 2, g.rows.select { |row| row.include?( Coord[:c1] ) }.length )
    assert_equal( 1, g.rows.select { |row| row.include?( Coord[:c6] ) }.length )
    assert_equal( 1, g.rows.select { |row| row.include?( Coord[:h6] ) }.length )

    g << "c1"

    assert_equal( 1, g.rows.select { |row| row.include?( Coord[:c6] ) }.length )
    assert_equal( 1, g.rows.select { |row| row.include?( Coord[:h6] ) }.length )

    assert( ! g.moves.include?( "c6" ) )
    assert( ! g.moves.include?( "h6" ) )

    g << ["c2", "c3", "c4", "c5"]

    assert_equal( :white, g.turn )
    assert_equal( 2, g.rows.length )
    assert_equal( ["b7", "c8", "d9", "f3"].sort,
                  g.moves.map { |m| m.to_s }.sort )

    g << "b7"

    assert_equal( :white, g.turn )
    assert_equal( 1, g.rows.length )

    g << ["d2", "e3", "f4", "g5", "h6"]
    
    assert_equal( :white, g.turn )
    assert_equal( 1, g.rows.length )
    assert_equal( ["c8", "d9", "f3"].sort,
                  g.moves.map { |m| m.to_s }.sort )

    g << "c8"

    assert( g.final? )
    assert( g.winner?( :white ) )
    assert( g.loser?( :black ) )
    assert( ! g.winner?( :black ) )
    assert( ! g.loser?( :white ) )
    assert( ! g.draw? )
    assert_equal( 3, g.score( :white ) )
  end

  def test_out_of_markers
    g = play_sequence ["b1", "c1", "d1", "e1", 
                       "a2", "b2", "c2", "d2", "e2", "f2", 
                       "a2a3", "b2b3", "c2c3", "d2d3", "e2e3", "f2f3", 
                       "a3a4", "e1g3", "c3c4", "b3b4", "e3e4", "c1f4", "a4a5", 
                       "d3d4", "c4c5", "f3g4", "e4e5", "g3g2", "b1f5", "b4b5", 
                       "a5b6", "f4g5", "c5c6", "d4d5", "e5e6", "g4h4", "d1h5", 
                       "g2h3", "f5f6", "g5g6", "b6b7", "d5d6", "c6c7", "b5d7", 
                       "e6e7", "h4i4", "h5h6", "g6g7", "f6f7", "d7d8", "b7c8", 
                       "i4i5", "e7e8", "h3j5", "h6h7", "d6i6", "f7f8", "g7g8", 
                       "c8d9", "d8e9", "d8", "d7", "d6", "d5", "d4", "i5", 
                       "c7d7", "j5j6", "e8d8", "i6i5", "h7h8", "g8g9"]

    assert_equal( 0, g.markers_remaining )

    assert( !g.draw? )
    assert( g.winner?( :black ) )
    assert( !g.loser?( :black ) )
    assert( !g.winner?( :white ) )
    assert( g.loser?( :white ) )
  end

end

