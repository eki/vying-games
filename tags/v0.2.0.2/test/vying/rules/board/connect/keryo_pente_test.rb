require 'test/unit'

require 'vying'
require 'vying/rules/rules_test'

class TestKeryoPente < Test::Unit::TestCase
  include RulesTests

  def rules
    KeryoPente
  end

  def test_info
    assert_equal( "Keryo-Pente", KeryoPente.info[:name] )
  end

  def test_players
    assert_equal( [:white,:black], KeryoPente.players )
    assert_equal( [:white,:black], KeryoPente.new.players )
  end

  def test_init
    g = Game.new( KeryoPente )
    assert_equal( Board.new( 19, 19 ), g.board )
    assert_equal( :white, g.turn )
    assert_equal( 19*19, g.unused_ops.length )
    assert_equal( 'a1', g.unused_ops.first )
    assert_equal( 's19', g.unused_ops.last )
  end

  def test_has_score
    g = Game.new( KeryoPente )
    assert( g.has_score? )
  end

  def test_has_ops
    g = Game.new( KeryoPente )
    assert_equal( [:white], g.has_ops )
    g << g.ops.first
    assert_equal( [:black], g.has_ops )
  end

  def test_ops
    g = Game.new( KeryoPente )
    ops = g.ops

    assert_equal( 'a1', ops[0] )
    assert_equal( 'b1', ops[1] )
    assert_equal( 'c1', ops[2] )
    assert_equal( 'd1', ops[3] )
    assert_equal( 'e1', ops[4] )
    assert_equal( 'f1', ops[5] )
    assert_equal( 'g1', ops[6] )
    assert_equal( 's19', ops[19*19-1] )

    while ops = g.ops do
      g << ops[0]
    end

    assert_not_equal( g.history[0], g.history.last )
  end

  def test_capture01
    g = Game.new( KeryoPente )
    g << [:b2,:b1,:b3]
    
    assert_equal( 0, g.score( :black ) )
    assert_equal( 0, g.score( :white ) )
    assert_equal( :white, g.board[:b2] )
    assert_equal( :white, g.board[:b3] )
    assert_equal( :black, g.board[:b1] )
    assert( !g.op?( :b2 ) )
    assert( !g.op?( :b3 ) )
    assert( !g.op?( :b1 ) )

    g << :b4

    assert_equal( 2, g.score( :black ) )
    assert_equal( 0, g.score( :white ) )
    assert_equal( nil, g.board[:b2] )
    assert_equal( nil, g.board[:b3] )
    assert_equal( :black, g.board[:b1] )
    assert_equal( :black, g.board[:b4] )
    assert( g.op?( :b2 ) )
    assert( g.op?( :b3 ) )
    assert( !g.op?( :b1 ) )
    assert( !g.op?( :b4 ) )
  end

  def test_capture02
    g = Game.new( KeryoPente )
    g << [:b2,:a1,:c3]
    
    assert_equal( 0, g.score( :black ) )
    assert_equal( 0, g.score( :white ) )
    assert_equal( :white, g.board[:b2] )
    assert_equal( :white, g.board[:c3] )
    assert_equal( :black, g.board[:a1] )
    assert( !g.op?( :b2 ) )
    assert( !g.op?( :c3 ) )
    assert( !g.op?( :a1 ) )

    g << :d4

    assert_equal( 2, g.score( :black ) )
    assert_equal( 0, g.score( :white ) )
    assert_equal( nil, g.board[:b2] )
    assert_equal( nil, g.board[:c3] )
    assert_equal( :black, g.board[:a1] )
    assert_equal( :black, g.board[:d4] )
    assert( g.op?( :b2 ) )
    assert( g.op?( :c3 ) )
    assert( !g.op?( :a1 ) )
    assert( !g.op?( :d4 ) )
  end

  def test_capture03
    g = Game.new( KeryoPente )
    g << [:b2,:b1,:b3,:a9,:b4]
    
    assert_equal( 0, g.score( :black ) )
    assert_equal( 0, g.score( :white ) )
    assert_equal( :white, g.board[:b2] )
    assert_equal( :white, g.board[:b3] )
    assert_equal( :black, g.board[:b1] )
    assert( !g.op?( :b2 ) )
    assert( !g.op?( :b3 ) )
    assert( !g.op?( :b1 ) )
    assert( !g.op?( :b4 ) )
    assert( !g.op?( :a9 ) )

    g << :b5

    assert_equal( 3, g.score( :black ) )
    assert_equal( 0, g.score( :white ) )
    assert_equal( nil, g.board[:b2] )
    assert_equal( nil, g.board[:b3] )
    assert_equal( nil, g.board[:b4] )
    assert_equal( :black, g.board[:b1] )
    assert_equal( :black, g.board[:b5] )
    assert( g.op?( :b2 ) )
    assert( g.op?( :b3 ) )
    assert( g.op?( :b4 ) )
    assert( !g.op?( :b1 ) )
    assert( !g.op?( :b5 ) )
    assert( !g.op?( :a9 ) )
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

