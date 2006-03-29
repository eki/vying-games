
require "test/unit"
require "game"

class TestPlayer < Test::Unit::TestCase
  def test_initialize
    p = Player.new( 'Alpha', 'a' )
    assert_equal( 'Alpha', p.name )
    assert_equal( 'a', p.short )

    p = Player.new( 'Beta', 'b' )
    assert_equal( 'Beta', p.name )
    assert_equal( 'b', p.short )
  end

  def test_equal
    p1 = Player.new( 'Alpha', 'a' )
    p2 = Player.new( 'Beta', 'b' )
    p3 = p1.dup

    assert_equal( p1, p3 )
    assert_not_equal( p1, p2 )
    assert_not_equal( p2, p3 )

    assert( p1 == p3 )
    assert( p1.eql?( p3 ) )
    assert( p1 != p2 )
    assert( p2 != p3 )
  end

  def test_hash
    p1 = Player.new( 'Alpha', 'a' )
    p2 = Player.new( 'Beta', 'b' )
    p3 = p1.dup

    assert_equal( p1.hash, p3.hash )
    assert_not_equal( p1.hash, p2.hash )
    assert_not_equal( p2.hash, p3.hash )
  end

  def test_to_s
    assert_equal( "Red (r)", Player.red.to_s )
    assert_equal( "X (x)", Player.x.to_s )
    assert_equal( "Player 1 (1)", Player.new( "Player 1", "1" ).to_s )
  end

  def test_method_missing
    p1 = Player.new( 'Beta', 'b' )
    p2 = Player.beta

    assert_equal( p1, p2 )
  end
end

class TestPlayerSet < Test::Unit::TestCase
  def test_initialize
    ps = PlayerSet.new( Player.north, Player.east, Player.south, Player.west )
    
    assert_equal( [Player.north, Player.east, Player.south, Player.west],
                  ps.players )
                  
    assert_equal( 'North', ps.name )
    assert_equal( 'n', ps.short )
  end

  def test_next!
    ps = PlayerSet.new( Player.north, Player.east, Player.south, Player.west )

    assert_equal( Player.east,  ps.next! )
    assert_equal( Player.south, ps.next! )
    assert_equal( Player.west,  ps.next! )
    assert_equal( Player.north, ps.next! )
    assert_equal( Player.east,  ps.next! )
  end

  def test_previous!
    ps = PlayerSet.new( Player.north, Player.east, Player.south, Player.west )

    assert_equal( Player.west,  ps.previous! )
    assert_equal( Player.south, ps.previous! )
    assert_equal( Player.east,  ps.previous! )
    assert_equal( Player.north, ps.previous! )
    assert_equal( Player.west,  ps.previous! )
  end

  def test_current
    ps = PlayerSet.new( Player.north, Player.east, Player.south, Player.west )

    assert_equal( Player.north, ps.current )

    ps.next!
    assert_equal( Player.east, ps.current )

    ps.next!.next!.next!
    assert_equal( Player.north, ps.current )
  end

  def test_next
    ps = PlayerSet.new( Player.north, Player.east, Player.south, Player.west )

    assert_equal( Player.east,  ps.next )
    assert_equal( Player.north, ps.current )

    assert_equal( Player.west,  ps.next!.next!.next! )
    assert_equal( Player.north, ps.next )
    assert_equal( Player.west,  ps.current )
  end

  def test_previous
    ps = PlayerSet.new( Player.north, Player.east, Player.south, Player.west )

    assert_equal( Player.west,  ps.previous )
    assert_equal( Player.north, ps.current )

    assert_equal( Player.east,  ps.previous!.previous!.previous! )
    assert_equal( Player.north, ps.previous )
    assert_equal( Player.east,  ps.current )
  end

end

class FakeRules

  Position = Struct.new( :fake_board, :fake_player )

  def FakeRules.init
    Position.new( "edcba", "player1" )
  end

  def FakeRules.op?( position, op )
    op.to_s =~ /(r|s)/
  end

  def FakeRules.ops( position )
    return nil if final?( position )
    ['r','s']
  end

  def FakeRules.apply( position, op )
    if op.to_s =~ /r/
      pos = position.dup
      pos.fake_board.succ!
      return pos
    elsif op.to_s =~ /s/
      pos = position.dup
      pos.fake_board.squeeze!
      pos
    end
  end

#  def FakeRules.ops( position )
#    return nil if final?( position )
#
#    op1 = Op.new( "Succ!", 'r' ) do
#      s = position.dup
#      s.fake_board.succ!
#      s
#    end
#
#    op2 = Op.new( "Squeeze!", 's' ) do
#      s = position.dup
#      s.fake_board.squeeze!
#      s
#    end
#
#    [op1,op2]
#  end

  def FakeRules.final?( position )
    position.fake_board.length == 1
  end
end

class TestGame < Test::Unit::TestCase
  def test_initialize
    g = Game.new( FakeRules )
    assert_equal( FakeRules, g.rules )
    assert_equal( [], g.sequence )
    assert_equal( [FakeRules.init], g.history )
    assert_equal( "edcba", g.fake_board )
    assert_equal( "player1", g.fake_player )
  end

  def test_ops
    g = Game.new( FakeRules )
    ops = g.ops

    assert_equal( "r", ops[0] )
    assert_equal( "s", ops[1] )

    g << ops[0]

    assert_equal( [ops[0]], g.sequence )
    assert_equal( "edcbb", g.fake_board )

    g << (op = g.ops[1])

    assert_equal( op, g.sequence.last )
    assert_equal( "edcb", g.fake_board )

    g << 'r'
    g << 's'

    assert_equal( "edc", g.fake_board )
  end

  def test_final
    g = Game.new( FakeRules ) # edcba
    g << g.ops[0] # edcbb
    assert( !g.final? )
    g << g.ops[1] # edcb
    assert( !g.final? )
    g << g.ops[0] # edcc
    assert( !g.final? )
    g << g.ops[1] # edc
    assert( !g.final? )
    g << g.ops[0] # edd
    assert( !g.final? )
    g << g.ops[1] # ed
    assert( !g.final? )
    g << g.ops[0] # ee
    assert( !g.final? )
    g << g.ops[1] # e
    assert( g.final? )
    assert( g.ops.nil? )
  end
end

