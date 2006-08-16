
require "test/unit"
require "game"

class FakeRules < Rules

  attr_reader :fake_board, :fake_foo

  info :name => "Fake Rules"

  random

  players [:a, :b, :c]

  censor :a => [:fake_foo],
         :b => [:fake_board]

  def initialize( seed=nil )
    super

    @fake_board, @fake_foo = "edcba", "bar"
  end

  def op?( op )
    op.to_s =~ /(r|s)/
  end

  def ops
    return nil if final?
    ['r','s']
  end

  def apply!( op )
    if op.to_s =~ /r/
      fake_board.succ!
    elsif op.to_s =~ /s/
      fake_board.squeeze!
    end
    self
  end

  def final?
    fake_board.length == 1
  end
end

class TestGame < Test::Unit::TestCase
  def test_initialize
    g = Game.new( FakeRules, 1000 )
    assert_equal( FakeRules, g.rules )
    assert_equal( [], g.sequence )
    assert_equal( [FakeRules.new( 1000 )], g.history )
    assert_equal( "edcba", g.fake_board )
    assert_equal( "bar", g.fake_foo )
    assert_equal( :a, g.turn )
    assert( g.respond_to?( :seed ) )
    assert( g.respond_to?( :rng ) )
  end

  def test_censor
    g = Game.new( FakeRules )
    assert_equal( :hidden, g.censor( :a ).rng )
    assert_equal( :hidden, g.censor( :b ).rng )
    assert_equal( :hidden, g.censor( :c ).rng )
    assert_equal( :hidden, g.censor( :a ).fake_foo )
    assert_equal( :hidden, g.censor( :b ).fake_board )
    assert_not_equal( :hidden, g.censor( :a ).fake_board )
    assert_not_equal( :hidden, g.censor( :b ).fake_foo )
    assert_not_equal( :hidden, g.censor( :c ).fake_board )
    assert_not_equal( :hidden, g.censor( :c ).fake_foo )
  end

  def test_turn
    g = Game.new( FakeRules )
    assert_equal( :a, g.turn )
    assert_equal( :a, g.turn( :now ) )
    assert_equal( :b, g.turn( :next ) )
    assert_equal( :b, g.turn( :rotate ) )
    assert_equal( :b, g.turn )
    assert_equal( :c, g.turn( :rotate ) )
    assert_equal( :c, g.turn )
    assert_equal( :a, g.turn( :next ) )
    assert_equal( :a, g.turn( :rotate ) )
    assert_equal( :a, g.turn )
  end

  def test_has_ops
    g = Game.new( FakeRules )
    assert_equal( [:a], g.has_ops )
    g.turn( :rotate )
    assert_equal( [:b], g.has_ops )
    g.turn( :rotate )
    assert_equal( [:c], g.has_ops )
    g.turn( :rotate )
    assert_equal( [:a], g.has_ops )
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

