module RulesTests
  def test_interface
    r = rules.new
    assert( r.respond_to?( :op? ) )
    assert( r.respond_to?( :ops ) )
    assert( r.respond_to?( :apply ) )
    assert( r.respond_to?( :apply! ) )
    assert( r.respond_to?( :has_ops ) )
    assert( r.respond_to?( :censor ) )
    assert( r.respond_to?( :final? ) )
    assert( r.respond_to?( :winner? ) )
    assert( r.respond_to?( :loser? ) )
    assert( r.respond_to?( :draw? ) )
  end

  def test_dup # This test uses rand!  This could be bad in some cases...
    g = Game.new( rules )
    30.times do                          # Take two steps forward,
      p = g.history.last.dup             # one step back
      g << g.ops[rand(g.ops.size)]       # Make sure that dup'ed positions
      assert_not_equal( p, g.undo )      # are not corrupted
      assert_equal( p, g.history.last )
      g << g.ops[rand(g.ops.size)]
    end
  end

  def play_sequence( s )
    g = Game.new( rules )
    g << s[0,s.size-1]
    assert( !g.final? )
    g << s[-1]
    assert( g.final? )
    assert( !g.ops )
    assert( !g.op?( s[-1] ) )
    g
  end

  def test_op?
    g = Game.new( rules )

    g.ops.each do |op|
      assert( g.op?( op ) )
      g.has_ops.each { |p| assert( g.op?( op, p ) ) }
      (g.players - g.has_ops).each { |p| assert( !g.op?( op, p ) ) }
    end

    g << g.ops.first

    g.ops.each do |op|
      assert( g.op?( op ) )
      g.has_ops.each { |p| assert( g.op?( op, p ) ) }
      (g.players - g.has_ops).each { |p| assert( !g.op?( op, p ) ) }
    end
  end
end

