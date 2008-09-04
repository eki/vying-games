require 'test/unit'

require 'vying'
require 'vying/rules/rules_test'

class TestKalah < Test::Unit::TestCase
  include RulesTests

  def rules
    Kalah
  end

  def test_info
    assert_equal( "Kalah", rules.name )
    assert( rules.version > "1.0.0" )
  end

  def test_players
    assert_equal( [:one,:two], rules.new.players )
  end

  def test_initialize
    g = new_game

    b = MancalaBoard.new( 6, 2, 6 )

    assert_equal( b, g.board )
    assert_equal( :one, g.turn )
    assert_equal( 0, g.score( :one ) )
    assert_equal( 0, g.score( :two ) )
  end

  def test_moves
    g = new_game

    assert_equal( :one, g.turn )
    assert_equal( ['a1', 'b1', 'c1', 'd1', 'e1', 'f1'], g.moves )

    g << :a1

    assert_equal( :two, g.turn )
    assert_equal( ['a2', 'b2', 'c2', 'd2', 'e2', 'f2'], g.moves )

    g << :f2

    assert_equal( :one, g.turn )
    assert_equal( ['b1', 'c1', 'd1', 'e1', 'f1'], g.moves )

    g << :f1

    assert_equal( :two, g.turn )
    assert_equal( ['a2', 'b2', 'c2', 'd2', 'e2'], g.moves )

    g << :e2

    assert_equal( :one, g.turn )
    assert_equal( ['a1', 'b1', 'c1', 'd1', 'e1', 'f1'], g.moves )

    g << :a1

    assert_equal( :one, g.turn )
    assert_equal( ['b1', 'c1', 'd1', 'e1', 'f1'], g.moves )

    g << g.moves.first until g.final?

    assert_not_equal( g.history.first, g.history.last )
  end

  def test_has_score
    g = new_game
    g << g.moves.first

    assert( g.has_score? )
    assert_equal( 1, g.score( :one ) )
    assert_equal( 0, g.score( :two ) )
  end

  def test_capture
    g = new_game
    g << [:d1, :a2, :e1, :a2, :f1, :b2, :e1]

    assert_equal( 3, g.score( :one ) )
    assert_equal( 2, g.score( :two ) )
    assert_equal( 1, g.board[:a2] )
    assert_equal( 0, g.board[:b2] )
    assert_equal( 9, g.board[:a1] )
    assert_equal( 9, g.board[:b1] )

    g << :a2

    assert_equal( 3, g.score( :one ) )
    assert_equal( 12, g.score( :two ) )
    assert_equal( 0, g.board[:a2] )
    assert_equal( 0, g.board[:b2] )
    assert_equal( 9, g.board[:a1] )
    assert_equal( 0, g.board[:b1] )
  end

  def test_extra_turn
    g = new_game

    assert_equal( :one, g.turn )

    g << :f1
    
    assert_equal( :one, g.turn )

    g << :e1

    assert_equal( :two, g.turn )
  end

  def test_final
    g = new_game

    # Doctor the board

    g.board[:b1,:c1,:d1,:e1,:f1] = 0
    g.board[:a1] = 1
    g.board[:a2,:b2,:c2,:d2,:e2,:f2] = 3

    assert( !g.final? )
    assert_equal( 0, g.score( :one ) )
    assert_equal( 0, g.score( :two ) )
    assert_equal( ['a1'], g.moves )

    g << :a1

    assert( g.final? )
    assert_equal( 1, g.score( :one ) )
    assert_equal( 18, g.score( :two ) )
    assert( !g.winner?( :one ) )
    assert( g.winner?( :two ) )
    assert( g.loser?( :one ) )
    assert( !g.loser?( :two ) )
    assert( !g.draw? )
  end

end

