module RulesTests
  def test_interface
    r = rules.new
    assert( r.respond_to?( :move? ) )
    assert( r.respond_to?( :moves ) )
    assert( r.respond_to?( :apply ) )
    assert( r.respond_to?( :apply! ) )
    assert( r.respond_to?( :has_moves ) )
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
      g << g.moves[rand(g.moves.size)] 
      assert_not_equal( p, g.undo.first )      
      assert_equal( p, g.history.last )
      break if g.final?
      g << g.moves[rand(g.moves.size)]
    end
  end

  def play_sequence( s )
    g = Game.new( rules )
    g << s[0,s.size-1]
    assert( !g.final? )
    g << s[-1]
    assert( g.final? )
    assert( g.moves.empty? )
    assert( !g.move?( s[-1] ) )
    g
  end

  def test_move?
    g = Game.new( rules )

    g.moves.each do |move|
      assert( g.move?( move ) )
      (g.players - g.has_moves).each { |p| assert( !g.move?( move, p ) ) }
    end

    g.has_moves.each do |p| 
      g.moves( p ).each { |move| assert( g.move?( move, p ) ) }
    end

    g << g.moves.first

    g.moves.each do |move|
      assert( g.move?( move ) )
      g.has_moves.each { |p| assert( g.move?( move, p ) ) }
      (g.players - g.has_moves).each { |p| assert( !g.move?( move, p ) ) }
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

