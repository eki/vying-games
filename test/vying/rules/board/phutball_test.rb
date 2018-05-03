require_relative '../../../test_helper'

class TestPhutball < Minitest::Test
  include RulesTests

  def rules
    Phutball
  end

  def test_info
    assert_equal( "Phutball", rules.name )
  end

  def test_players
    assert_equal( [:ohs,:eks], rules.new.players )
  end

  def test_init
    g = Game.new( rules )

    b = Board.rect( 15, 21 )
    b[:h11] = :white

    assert_equal( b, g.board )

    assert_equal( :ohs, g.turn )
    assert_equal( [Coord[:h11]], g.board.occupied( :white ) )
    assert_equal( [], g.board.occupied( :black ) )
  end

  def test_has_score
    g = Game.new( rules )
    assert( !g.has_score? )
  end

  def test_has_moves
    g = Game.new( rules )
    assert_equal( [:ohs], g.has_moves )
    g << g.moves.first
    assert_equal( [:eks], g.has_moves )
  end

  def test_moves
    g = Game.new( rules )
    moves = g.moves

    assert_equal( 'a2', moves[0].to_s )
    assert_equal( 'b2', moves[1].to_s )
    assert_equal( 'c2', moves[2].to_s )
    assert_equal( 'd2', moves[3].to_s )
    assert_equal( 'e2', moves[4].to_s )
    assert_equal( 'f2', moves[5].to_s )
    assert_equal( 'g2', moves[6].to_s )
    assert_equal( 'o20', moves.last.to_s )

    g << g.moves.first

    refute_equal( g.history[0], g.history.last )
  end

  def test_jumping_moves
    g = Game.new( rules )
    g << :h10

    assert( g.moves.include?( "h11h9" ) )

    g << :h9

    assert( g.moves.include?( "h11h8" ) )

    g << :i11 << :j11 << :k11

    assert( g.moves.include?( "h11l11" ) )

    g << [:h12, :h13, :h14, :h15, :h16, :h17, :h18, :h19, :h20]

    assert( !g.moves.include?( "h21" ) )
    assert( g.moves.include?( "h11h21" ) )

    g << [:i10, :i12, :g10, :g11, :g12, :e14]

    assert( g.moves.include?( "h11j9" ) )
    assert( g.moves.include?( "h11j13" ) )
    assert( g.moves.include?( "h11f9" ) )
    assert( g.moves.include?( "h11f11" ) )
    assert( g.moves.include?( "h11f13" ) )
  end

  def test_jumping_01
    g = Game.new( rules )

    g << :h10

    assert( g.moves.include?( "h11h9" ) )

    g << "h11h9"

    assert_equal( nil, g.board[:h11] )
    assert_equal( nil, g.board[:h10] )
    assert_equal( :white, g.board[:h9] )

    assert( g.moves.include?( "h11" ) )
    assert( g.moves.include?( "h10" ) )
    assert( !g.moves.include?( "h9" ) )
    assert( !g.jumping )
  end

  def test_jumping_02
    g = Game.new( rules )

    g << [:i10, :j9, :k8, :l7, :m6, :n5]

    assert( g.moves.include?( "h11o4" ) )

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
    g = Game.new( rules )

    g << [:i10, :j9, :k8, :l7, :m6, :n5, :o4]

    assert( !g.moves.include?( "h11o4" ) )
    assert( !g.moves.include?( "h11p3" ) )
  end

  def test_jumping_04
    g = Game.new( rules )

    g << [:h10, :h8, :h7]

    assert( g.moves.include?( "h11h9" ) )
    assert( !g.moves.include?( "h11h8" ) )
    assert( !g.moves.include?( "h11h7" ) )

    assert( g.turn == :eks )

    g << :h11h9

    assert_equal( nil, g.board[:h11] )
    assert_equal( nil, g.board[:h10] )
    assert_equal( :white, g.board[:h9] )

    assert( g.jumping )
    assert( g.turn == :eks )

    assert( g.moves.include?( "h9h6" ) )
    assert( g.moves.include?( "pass" ) )
    assert( g.moves.length == 2 )

    g << :h9h6

    assert_equal( nil, g.board[:h9] )
    assert_equal( nil, g.board[:h8] )
    assert_equal( nil, g.board[:h7] )
    assert_equal( :white, g.board[:h6] )
    
    assert( g.moves.include?( "h9" ) )
    assert( g.moves.include?( "h8" ) )
    assert( g.moves.include?( "h7" ) )
    assert( !g.moves.include?( "h6" ) )

    assert( !g.jumping )
    assert( g.turn == :ohs )
  end

  def test_jumping_05
    g = Game.new( rules )

    g << [:h10, :h8, :h7]

    assert( g.moves.include?( "h11h9" ) )
    assert( !g.moves.include?( "h11h8" ) )
    assert( !g.moves.include?( "h11h7" ) )

    assert( g.turn == :eks )

    g << :h11h9

    assert_equal( nil, g.board[:h11] )
    assert_equal( nil, g.board[:h10] )
    assert_equal( :white, g.board[:h9] )

    assert( g.jumping )
    assert( g.turn == :eks )

    assert( g.moves.include?( "h9h6" ) )
    assert( g.moves.include?( "pass" ) )
    assert( g.moves.length == 2 )

    g << :pass

    assert( !g.jumping )
    assert( g.turn == :ohs )

    assert( g.moves.include?( "h9h6" ) )
    assert( !g.moves.include?( :pass ) )
    assert( g.moves.length > 2 )

    assert( g.moves.include?( "h11" ) )
    assert( g.moves.include?( "h10" ) )
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

end

