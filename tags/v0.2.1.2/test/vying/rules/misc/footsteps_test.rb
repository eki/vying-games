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

  def test_has_ops
    g = Game.new( Footsteps )
    assert_equal( [:left, :right], g.has_ops )
    g << "left_1"
    assert_equal( [:right], g.has_ops )
    g << "right_1"
    assert_equal( [:left, :right], g.has_ops )
    g << "right_2"
    assert_equal( [:left], g.has_ops )
  end


# def test_game01
#   g = play_sequence( [:h10,:h9,:h8,:h7,:h6,:h5,:h4,:h3,:h2,:h11h1] )
#
#   assert( !g.draw? )
#   assert( !g.winner?( :eks ) )
#   assert( g.loser?( :eks ) )
#   assert( g.winner?( :ohs ) )
#   assert( !g.loser?( :ohs ) )
# end
#
# def test_game02
#   g = play_sequence( [:h12,:h13,:h14,:h15,:h16,:h17,:h18,:h19,:h11h20] )
#
#   assert( !g.draw? )
#   assert( g.winner?( :eks ) )
#   assert( !g.loser?( :eks ) )
#   assert( !g.winner?( :ohs ) )
#   assert( g.loser?( :ohs ) )
# end
#
## def test_game02
##   # This game is going to be a win for White (diagonal)(winner in middle)
##   g = play_sequence( [:f13,:a1,:c3,:f12,:f11,:d4,:e5,:f14,:f10,:f6,:b2] )
#
##   assert( !g.draw? )
##   assert( !g.winner?( :black ) )
##   assert( g.loser?( :black ) )
##   assert( g.winner?( :white ) )
##   assert( !g.loser?( :white ) )
## end
#
## def test_game03
##   # This game is going to be a win for Black (horizontal)(7-in-a-row)
##   g = play_sequence [:a1,:f10,:f9,:b1,:c1,:g10,:g9,:e1,:f1,:g8,:g7,:g1,:d1]
#
##   assert( !g.draw? )
##   assert( g.winner?( :black ) )
##   assert( !g.loser?( :black ) )
##   assert( !g.winner?( :white ) )
##   assert( g.loser?( :white ) )
## end

end

