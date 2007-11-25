require 'test/unit'

require 'vying'
require 'vying/rules/rules_test'

class TestFootsteps < Test::Unit::TestCase
  include RulesTests

  def rules
    Footsteps
  end

  def test_info
    assert_equal( "Footsteps", Footsteps.info[:name] )
  end

  def test_players
    assert_equal( [:left, :right], Footsteps.players )
    assert_equal( [:left, :right], Footsteps.new.players )
  end

  def test_init
    g = Game.new( Footsteps )

    b = Board.new( 7, 1 )
    b[:d1] = :white

    assert_equal( b, g.board )
  end

  def test_has_score
    g = Game.new( Footsteps )
    assert( !g.has_score? )
  end

  def test_has_moves
    g = Game.new( Footsteps )
    assert_equal( [:left, :right], g.has_moves )
    assert( g.has_moves.include?( g.turn ) )
    g << "left_1"
    assert_equal( [:right], g.has_moves )
    assert( g.has_moves.include?( g.turn ) )
    g << "right_1"
    assert_equal( [:left, :right], g.has_moves )
    assert( g.has_moves.include?( g.turn ) )
    g << "right_2"
    assert_equal( [:left], g.has_moves )
    assert( g.has_moves.include?( g.turn ) )
  end

  def test_game01
    g = play_sequence( [:left_50, :right_40, 
                        :right_1, :right_1, :right_1, :right_1] )

    assert( !g.draw? )
    assert( !g.winner?( :left ) )
    assert( g.loser?( :left ) )
    assert( g.winner?( :right ) )
    assert( !g.loser?( :right ) )
  end

  def test_game02
    g = play_sequence( [:left_10, :right_9, 
                        :right_8,  :left_9,
                         :left_2, :right_1] )

    assert( !g.draw? )
    assert( g.winner?( :left ) )
    assert( !g.loser?( :left ) )
    assert( !g.winner?( :right ) )
    assert( g.loser?( :right ) )
  end

  def test_game03
    g = play_sequence( [:left_10, :right_9, 
                        :right_9,  :left_8,
                        :left_20, :right_20,
                        :right_10, :left_10,
                        :left_1, :right_1, :left_1, :right_1] )

    assert( g.draw? )
    assert( !g.winner?( :left ) )
    assert( !g.loser?( :left ) )
    assert( !g.winner?( :right ) )
    assert( !g.loser?( :right ) )
  end

end

