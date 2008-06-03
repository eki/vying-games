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
    assert_equal( 3, g.board.occupied[:red].length )
    assert_equal( 3, g.board.occupied[:blue].length )
    assert_equal( :red, g.turn )

    
    g = Game.new( rules, 1234, :number_of_players => 2 )

    assert_equal( 5, g.board.length )
    assert_equal( [:red, :red, :red], g.board[:a1,:i5,:e9] )
    assert_equal( [:blue, :blue, :blue], g.board[:e1,:a5,:i9] )
    assert_equal( 3, g.board.occupied[:red].length )
    assert_equal( 3, g.board.occupied[:blue].length )
    assert_equal( :red, g.turn )


    g = Game.new( rules, 1234, :number_of_players => 3 )

    assert_equal( 5, g.board.length )
    assert_equal( [:red, :red], g.board[:a5,:i5] )
    assert_equal( [:blue, :blue], g.board[:a1,:i9] )
    assert_equal( [:white, :white], g.board[:e1,:e9] )
    assert_equal( 2, g.board.occupied[:red].length )
    assert_equal( 2, g.board.occupied[:blue].length )
    assert_equal( 2, g.board.occupied[:white].length )
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
    g.clear_blocks
    g.set_blocks( "" )

    moves = g.moves

#   assert_equal( ["a1b1", "a1a2", "a1b2", 
#                  "g7f6", "g7g6", "g7f7", 
#                  "a1c1", "a1c2", "a1a3", "a1b3", "a1c3", 
#                  "g7e5", "g7f5", "g7g5", "g7e6", "g7e7"].sort, moves.sort )

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
    g.clear_blocks
    g.set_blocks( "" )

#   g << "a1a2"

#   assert( g.has_score? )
#   assert_equal( 3, g.score( :red ) )
#   assert_equal( 2, g.score( :blue ) )
  end

end

