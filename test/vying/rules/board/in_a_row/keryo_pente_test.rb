require 'test/unit'

require 'vying'
require 'vying/rules/rules_test'

class TestKeryoPente < Test::Unit::TestCase
  include RulesTests

  def rules
    KeryoPente
  end

  def test_info
    assert_equal( "Keryo-Pente", rules.name )
  end

  def test_players
    assert_equal( [:white,:black], rules.new.players )
  end

  def test_init
    g = Game.new( rules )
    assert_equal( :white, g.turn )
    assert_equal( :square, g.board.shape )
    assert_equal( 19, g.board.length )
    assert_equal( 19*19, g.board.unoccupied.length )
    assert_equal( 5, g.board.window_size )
    assert_equal( [], g.board.threats )
  end

  def test_has_score
    g = Game.new( rules )
    assert( g.has_score? )
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

    assert_equal( 'a1', moves[0].to_s )
    assert_equal( 'b1', moves[1].to_s )
    assert_equal( 'c1', moves[2].to_s )
    assert_equal( 'd1', moves[3].to_s )
    assert_equal( 'e1', moves[4].to_s )
    assert_equal( 'f1', moves[5].to_s )
    assert_equal( 'g1', moves[6].to_s )
    assert_equal( 's19', moves[19*19-1].to_s )

    g << g.moves.first until g.final?

    assert_not_equal( g.history[0], g.history.last )
  end

  def test_capture01
    g = Game.new( rules )
    g << [:b2,:b1,:b3]
    
    assert_equal( 0, g.score( :black ) )
    assert_equal( 0, g.score( :white ) )
    assert_equal( :white, g.board[:b2] )
    assert_equal( :white, g.board[:b3] )
    assert_equal( :black, g.board[:b1] )
    assert( !g.move?( :b2 ) )
    assert( !g.move?( :b3 ) )
    assert( !g.move?( :b1 ) )

    g << :b4

    assert_equal( 2, g.score( :black ) )
    assert_equal( 0, g.score( :white ) )
    assert_equal( nil, g.board[:b2] )
    assert_equal( nil, g.board[:b3] )
    assert_equal( :black, g.board[:b1] )
    assert_equal( :black, g.board[:b4] )
    assert( g.move?( :b2 ) )
    assert( g.move?( :b3 ) )
    assert( !g.move?( :b1 ) )
    assert( !g.move?( :b4 ) )
  end

  def test_capture02
    g = Game.new( rules )
    g << [:b2,:a1,:c3]
    
    assert_equal( 0, g.score( :black ) )
    assert_equal( 0, g.score( :white ) )
    assert_equal( :white, g.board[:b2] )
    assert_equal( :white, g.board[:c3] )
    assert_equal( :black, g.board[:a1] )
    assert( !g.move?( :b2 ) )
    assert( !g.move?( :c3 ) )
    assert( !g.move?( :a1 ) )

    g << :d4

    assert_equal( 2, g.score( :black ) )
    assert_equal( 0, g.score( :white ) )
    assert_equal( nil, g.board[:b2] )
    assert_equal( nil, g.board[:c3] )
    assert_equal( :black, g.board[:a1] )
    assert_equal( :black, g.board[:d4] )
    assert( g.move?( :b2 ) )
    assert( g.move?( :c3 ) )
    assert( !g.move?( :a1 ) )
    assert( !g.move?( :d4 ) )
  end

  def test_capture03
    g = Game.new( rules )
    g << [:b2,:b1,:b3,:a9,:b4]
    
    assert_equal( 0, g.score( :black ) )
    assert_equal( 0, g.score( :white ) )
    assert_equal( :white, g.board[:b2] )
    assert_equal( :white, g.board[:b3] )
    assert_equal( :black, g.board[:b1] )
    assert( !g.move?( :b2 ) )
    assert( !g.move?( :b3 ) )
    assert( !g.move?( :b1 ) )
    assert( !g.move?( :b4 ) )
    assert( !g.move?( :a9 ) )

    g << :b5

    assert_equal( 3, g.score( :black ) )
    assert_equal( 0, g.score( :white ) )
    assert_equal( nil, g.board[:b2] )
    assert_equal( nil, g.board[:b3] )
    assert_equal( nil, g.board[:b4] )
    assert_equal( :black, g.board[:b1] )
    assert_equal( :black, g.board[:b5] )
    assert( g.move?( :b2 ) )
    assert( g.move?( :b3 ) )
    assert( g.move?( :b4 ) )
    assert( !g.move?( :b1 ) )
    assert( !g.move?( :b5 ) )
    assert( !g.move?( :a9 ) )
  end

  def test_game01
    g = play_sequence [:a1,:b1,:a2,:b2,:a3,:b3,:a4,:b4,:a5]

    assert( !g.draw? )
    assert( !g.winner?( :black ) )
    assert( g.loser?( :black ) )
    assert( g.winner?( :white ) )
    assert( !g.loser?( :white ) )
  end

  def test_game02
    g = play_sequence [:a5,:b5,:a4,:b4,:a3,:b3,:a2,:b2,:a1]

    assert( !g.draw? )
    assert( !g.winner?( :black ) )
    assert( g.loser?( :black ) )
    assert( g.winner?( :white ) )
    assert( !g.loser?( :white ) )
  end

  def test_game03
    g = play_sequence [:a5,:b5,:b4,:c4,:c3,:d3,:d2,:e2,:j1,:f1]

    assert( !g.draw? )
    assert( g.winner?( :black ) )
    assert( !g.loser?( :black ) )
    assert( !g.winner?( :white ) )
    assert( g.loser?( :white ) )
  end

  def test_game04
    g = play_sequence [:b2,:b1,:b3,:b4,                     # capture 1
                       :d7,:e7,:c7,:b7,                     # capture 2
                       :m7,:l6,:n8,:r12,:p10,:a1,:q11,:o9,  # capture 3 & 4
                       :s18,:s19,:s17,:s16,                 # capture 5
                       :k2,:k1,:k3,:j1,:k4,:k5,             # capture 6 (3)
                       :j2,:k6,:j3,:j4]                     # capture 7

    assert( !g.draw? )
    assert( g.winner?( :black ) )
    assert( !g.loser?( :black ) )
    assert( !g.winner?( :white ) )
    assert( g.loser?( :white ) )
  end

end

