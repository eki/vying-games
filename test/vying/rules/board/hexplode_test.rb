require_relative '../../../test_helper'

class TestHexplode < Minitest::Test
  include RulesTests

  def rules
    Hexplode
  end

  def test_info
    assert_equal( "Hexplode", rules.name )
  end

  def test_players
    assert_equal( [:red,:blue], rules.new.players )
  end

  def test_initialize
    g = Game.new( rules )
    assert_equal( :red, g.turn )
    assert_equal( 5, g.board.width )
    assert_equal( 5, g.board.height )
    assert_equal( :hexagon, g.board.cell_shape )
    assert_equal( :rhombus, g.board.shape )
    assert_equal( 0, g.board.count )
  end

  def test_has_moves
    g = Game.new( rules )
    assert_equal( [:red], g.has_moves )
    g << g.moves.first
    assert_equal( [:blue], g.has_moves )
    g << g.moves.first
    assert_equal( [:red], g.has_moves )
  end

  def test_game01
    g = play_sequence [:a1, :b1, :a1]

    assert( !g.draw? )
    assert( g.winner?( :red ) )
    assert( !g.loser?( :red ) )
    assert( !g.winner?( :blue ) )
    assert( g.loser?( :blue ) )
  end

  def test_game02
    g = play_sequence [:b1, :b2, :b1, :b2, :b1, :b2, :c1, :b2, :c1, :b2, :c1,
                       :b2]

    assert_equal( 0, g.score( :red ) )
    assert_equal( 12, g.score( :blue ) )

    [:a1, :a3, :b1, :b3, :c1, :d1].each do |c|
      assert_equal( 1, g.board[c].count, c )
    end

    [:a2, :b2, :c2].each do |c|
      assert_equal( 2, g.board[c].count, c )
    end

    assert( !g.draw? )
    assert( g.winner?( :blue ) )
    assert( !g.loser?( :blue ) )
    assert( !g.winner?( :red ) )
    assert( g.loser?( :red ) )
  end

end

