require 'test/unit'

require 'vying'
require 'vying/rules/rules_test'

class TestHexxagon < Test::Unit::TestCase
  include RulesTests

  def rules
    Hexxagon
  end

  def test_initialize
    g = Game.new( rules, 1234 )

    assert_equal( 5, g.board.length )
    assert_equal( [:red, :red, :red], g.board[:a1,:i5,:e9] )
    assert_equal( [:blue, :blue, :blue], g.board[:e1,:a5,:i9] )
    assert_equal( 3, g.board.count( :red ) )
    assert_equal( 3, g.board.count( :blue ) )
    assert_equal( :red, g.turn )

    
    g = Game.new( rules, 1234, :number_of_players => 2 )

    assert_equal( 5, g.board.length )
    assert_equal( [:red, :red, :red], g.board[:a1,:i5,:e9] )
    assert_equal( [:blue, :blue, :blue], g.board[:e1,:a5,:i9] )
    assert_equal( 3, g.board.count( :red ) )
    assert_equal( 3, g.board.count( :blue ) )
    assert_equal( :red, g.turn )

    g = Game.new( rules, 1234, :number_of_players => 3 )

    assert_equal( 5, g.board.length )
    assert_equal( [:red, :red], g.board[:a5,:i5] )
    assert_equal( [:blue, :blue], g.board[:a1,:i9] )
    assert_equal( [:white, :white], g.board[:e1,:e9] )
    assert_equal( 2, g.board.count( :red ) )
    assert_equal( 2, g.board.count( :blue ) )
    assert_equal( 2, g.board.count( :white ) )
    assert_equal( :red, g.turn )

    assert_raise( RuntimeError ) do
      Game.new( rules, 1234, :number_of_players => 1 )
    end
  
    assert_raise( RuntimeError ) do
      Game.new( rules, 1234, :number_of_players => 4 )
    end
  end

  def test_moves
    g = Game.new( rules, 1234 )

    g.board[* g.board.occupied( :x )] = nil

    moves = g.moves

    assert_equal( ["a1a2", "a1b1", "a1b2", "i5i6", "i5h5", "i5h4", "e9e8",
                   "e9f9", "e9d8", "a1c1", "a1c2", "a1a3", "a1b3", "a1c3", 
                   "i5g3", "i5g4", "i5g5", "i5h6", "i5i7", "e9c7", "e9d7", 
                   "e9e7", "e9f8", "e9g9"].sort, moves.sort )

    g << g.moves.first until g.final?

    assert_not_equal( g.history.first, g.history.last )
  end

  def test_players
    assert_equal( [:red,:blue], rules.new.players )
    assert_equal( [:red,:blue,:white], 
                  rules.new( :number_of_players => 3 ).players )
  end

  def test_has_score
    g = Game.new( rules, 1234 )

    g.board[* g.board.occupied( :x )] = nil

    g << "a1a2"

    assert( g.has_score? )
    assert_equal( 4, g.score( :red ) )
    assert_equal( 3, g.score( :blue ) )
  end

  def test_block_maps
    assert( rules.block_maps.keys.include?( 2 ) )
    assert( rules.block_maps.keys.include?( 3 ) )

    map_2p = rules.block_maps[2]

    assert( 61, 6 + map_2p.to_a.flatten.uniq.length )

    map_3p = rules.block_maps[3]

    assert( 61, 6 + map_3p.to_a.flatten.uniq.length )
  end

end

