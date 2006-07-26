
require "test/unit"
require "game"

class TestArray < Test::Unit::TestCase
  def test_rotate!
    ps = [:north, :east, :south, :west]

    assert_equal( :east,  ps.rotate!.now )
    assert_equal( :south, ps.rotate!.now )
    assert_equal( :west,  ps.rotate!.now )
    assert_equal( :north, ps.rotate!.now )
    assert_equal( :east,  ps.rotate!.now )
  end

  def test_now
    ps = [:north, :east, :south, :west]

    assert_equal( :north, ps.now )

    ps.rotate!
    assert_equal( :east, ps.now )

    ps.rotate!.rotate!.rotate!
    assert_equal( :north, ps.now )
  end

  def test_next
    ps = [:north, :east, :south, :west]

    assert_equal( :east,  ps.next )
    assert_equal( :north, ps.now )

    assert_equal( :west,  ps.rotate!.rotate!.rotate!.now )
    assert_equal( :north, ps.next )
    assert_equal( :west,  ps.now )
  end
end

class FakeRules < Rules

  position :fake_board, :fake_player

  def FakeRules.init( seed=nil )
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

