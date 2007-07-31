require 'test/unit'

require 'vying'
require 'vying/rules/rules_test'

class TestPhutball < Test::Unit::TestCase
  include RulesTests

  def rules
    Phutball
  end

  def test_info
    assert_equal( "Phutball", Phutball.info[:name] )
  end

  def test_players
    assert_equal( [:ohs,:eks], Phutball.players )
    assert_equal( [:ohs,:eks], Phutball.new.players )
  end

  def test_init
    g = Game.new( Phutball )

    b = Board.new( 15, 21 )
    b[:h11] = :white

    assert_equal( b, g.board )

    assert_equal( :ohs, g.turn )
    assert_equal( 15*19-1, g.unused_ops.length )
    assert_equal( 'a2', g.unused_ops.first )
    assert_equal( 'o20', g.unused_ops.last )
    assert_equal( [Coord[:h11]], g.board.occupied[:white] )
    assert_equal( nil, g.board.occupied[:black] )
  end

  def test_has_score
    g = Game.new( Phutball )
    assert( !g.has_score? )
  end

  def test_has_ops
    g = Game.new( Phutball )
    assert_equal( [:ohs], g.has_ops )
    g << g.ops.first
    assert_equal( [:eks], g.has_ops )
  end

  def test_ops
    g = Game.new( Phutball )
    ops = g.ops

    assert_equal( 'a2', ops[0] )
    assert_equal( 'b2', ops[1] )
    assert_equal( 'c2', ops[2] )
    assert_equal( 'd2', ops[3] )
    assert_equal( 'e2', ops[4] )
    assert_equal( 'f2', ops[5] )
    assert_equal( 'g2', ops[6] )
    assert_equal( 'o20', ops.last )

#    while ops = g.ops do
#      g << ops[0]
#    end

    g << g.ops.first

    assert_not_equal( g.history[0], g.history.last )
  end

  def test_jumping_ops
    g = Game.new( Phutball )
    g << :h10

    assert( g.ops.include?( "h11h9" ) )

    g << :h9

    assert( g.ops.include?( "h11h8" ) )

    g << :i11 << :j11 << :k11

    assert( g.ops.include?( "h11l11" ) )

    g << [:h12, :h13, :h14, :h15, :h16, :h17, :h18, :h19, :h20]

    assert( !g.ops.include?( "h21" ) )
    assert( g.ops.include?( "h11h21" ) )

    g << [:i10, :i12, :g10, :g11, :g12, :e14]

    assert( g.ops.include?( "h11j9" ) )
    assert( g.ops.include?( "h11j13" ) )
    assert( g.ops.include?( "h11f9" ) )
    assert( g.ops.include?( "h11f11" ) )
    assert( g.ops.include?( "h11f13" ) )
  end

  def test_jumping_01
    g = Game.new( Phutball )

    g << :h10

    assert( g.ops.include?( "h11h9" ) )

    g << "h11h9"

    assert_equal( nil, g.board[:h11] )
    assert_equal( nil, g.board[:h10] )
    assert_equal( :white, g.board[:h9] )

    assert( g.ops.include?( "h11" ) )
    assert( g.ops.include?( "h10" ) )
    assert( !g.ops.include?( "h9" ) )
    assert( !g.jumping )
  end

  def test_jumping_02
    g = Game.new( Phutball )

    g << [:i10, :j9, :k8, :l7, :m6, :n5]

    assert( g.ops.include?( "h11o4" ) )

    g << "h11o4"

    assert_equal( nil, g.board[:h11] )
    assert_equal( nil, g.board[:i10] )
    assert_equal( nil, g.board[:j9] )
    assert_equal( nil, g.board[:k8] )
    assert_equal( nil, g.board[:l7] )
    assert_equal( nil, g.board[:m6] )
    assert_equal( nil, g.board[:n5] )
    assert_equal( :white, g.board[:o4] )
  end

  def test_jumping_03
    g = Game.new( Phutball )

    g << [:i10, :j9, :k8, :l7, :m6, :n5, :o4]

    assert( !g.ops.include?( "h11o4" ) )
    assert( !g.ops.include?( "h11p3" ) )
  end

  def test_jumping_04
    g = Game.new( Phutball )

    g << [:h10, :h8, :h7]

    assert( g.ops.include?( "h11h9" ) )
    assert( !g.ops.include?( "h11h8" ) )
    assert( !g.ops.include?( "h11h7" ) )

    assert( g.turn == :eks )

    g << :h11h9

    assert_equal( nil, g.board[:h11] )
    assert_equal( nil, g.board[:h10] )
    assert_equal( :white, g.board[:h9] )

    assert( g.jumping )
    assert( g.turn == :eks )

    assert( g.ops.include?( "h9h6" ) )
    assert( g.ops.include?( "pass" ) )
    assert( g.ops.length == 2 )

    g << :h9h6

    assert_equal( nil, g.board[:h9] )
    assert_equal( nil, g.board[:h8] )
    assert_equal( nil, g.board[:h7] )
    assert_equal( :white, g.board[:h6] )
    
    assert( g.ops.include?( "h9" ) )
    assert( g.ops.include?( "h8" ) )
    assert( g.ops.include?( "h7" ) )
    assert( !g.ops.include?( "h6" ) )

    assert( !g.jumping )
    assert( g.turn == :ohs )
  end

  def test_jumping_05
    g = Game.new( Phutball )

    g << [:h10, :h8, :h7]

    assert( g.ops.include?( "h11h9" ) )
    assert( !g.ops.include?( "h11h8" ) )
    assert( !g.ops.include?( "h11h7" ) )

    assert( g.turn == :eks )

    g << :h11h9

    assert_equal( nil, g.board[:h11] )
    assert_equal( nil, g.board[:h10] )
    assert_equal( :white, g.board[:h9] )

    assert( g.jumping )
    assert( g.turn == :eks )

    assert( g.ops.include?( "h9h6" ) )
    assert( g.ops.include?( "pass" ) )
    assert( g.ops.length == 2 )

    g << :pass

    assert( !g.jumping )
    assert( g.turn == :ohs )

    assert( g.ops.include?( "h9h6" ) )
    assert( !g.ops.include?( :pass ) )
    assert( g.ops.length > 2 )

    assert( g.ops.include?( "h11" ) )
    assert( g.ops.include?( "h10" ) )
  end

 def test_game01
   g = play_sequence( [:h10,:h9,:h8,:h7,:h6,:h5,:h4,:h3,:h2,:h11h1] )

   assert( !g.draw? )
   assert( !g.winner?( :eks ) )
   assert( g.loser?( :eks ) )
   assert( g.winner?( :ohs ) )
   assert( !g.loser?( :ohs ) )
 end

 def test_game02
   g = play_sequence( [:h12,:h13,:h14,:h15,:h16,:h17,:h18,:h19,:h11h20] )

   assert( !g.draw? )
   assert( g.winner?( :eks ) )
   assert( !g.loser?( :eks ) )
   assert( !g.winner?( :ohs ) )
   assert( g.loser?( :ohs ) )
 end

# def test_game02
#   # This game is going to be a win for White (diagonal)(winner in middle)
#   g = play_sequence( [:f13,:a1,:c3,:f12,:f11,:d4,:e5,:f14,:f10,:f6,:b2] )

#   assert( !g.draw? )
#   assert( !g.winner?( :black ) )
#   assert( g.loser?( :black ) )
#   assert( g.winner?( :white ) )
#   assert( !g.loser?( :white ) )
# end

# def test_game03
#   # This game is going to be a win for Black (horizontal)(7-in-a-row)
#   g = play_sequence [:a1,:f10,:f9,:b1,:c1,:g10,:g9,:e1,:f1,:g8,:g7,:g1,:d1]

#   assert( !g.draw? )
#   assert( g.winner?( :black ) )
#   assert( !g.loser?( :black ) )
#   assert( !g.winner?( :white ) )
#   assert( g.loser?( :white ) )
# end

end

