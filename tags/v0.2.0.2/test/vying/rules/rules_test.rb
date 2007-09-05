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
      p = g.history.last.dup             # one step back, check for corruption
      break if g.final?
      g << g.ops[rand(g.ops.size)] 
      assert_not_equal( p, g.undo.first )      
      assert_equal( p, g.history.last )
      break if g.final?
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
      (g.players - g.has_ops).each { |p| assert( !g.op?( op, p ) ) }
    end

    g.has_ops.each { |p| g.ops( p ).each { |op| assert( g.op?( op, p ) ) } }

    g << g.ops.first

    g.ops.each do |op|
      assert( g.op?( op ) )
      g.has_ops.each { |p| assert( g.op?( op, p ) ) }
      (g.players - g.has_ops).each { |p| assert( !g.op?( op, p ) ) }
    end
  end

  def test_marshal
    g = Game.new( rules )
    g2 = nil
    assert_nothing_raised { g2 = Marshal::load( Marshal::dump( g ) ) }
    #assert_equal( g, g2 ) #Game doesn't implement ==
    assert_equal( g.history.last, g2.history.last )
  end

  def test_yaml
    g = Game.new( rules )
    g2 = nil
    assert_nothing_raised { g2 = YAML::load( YAML::dump( g ) ) }
    #assert_equal( g, g2 ) #Game doesn't implement ==
    assert_equal( g.history.last, g2.history.last )
  end

end

