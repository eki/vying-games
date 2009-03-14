
require 'vying'

module RulesTests
  include Vying

  def new_game( seed=nil, options={} )
    if seed.class == Hash
      seed, options = nil, seed
    end

    Game.new( rules, seed, options )
  end

  def test__interface
    r = rules.new
    assert( r.respond_to?( :move? ) )
    assert( r.respond_to?( :moves ) )
    assert( r.respond_to?( :apply ) )
    assert( r.respond_to?( :apply! ) )
    assert( r.respond_to?( :has_moves ) )
    assert( r.respond_to?( :has_moves? ) )
    assert( r.respond_to?( :censor ) )
    assert( r.respond_to?( :final? ) )
    assert( r.respond_to?( :winner? ) )
    assert( r.respond_to?( :loser? ) )
    assert( r.respond_to?( :draw? ) )
    assert( r.respond_to?( :instructions ) )
  end

  def test__arity
    r = rules.new

    assert_equal( -2, r.method( :move? ).arity )
    assert_equal( -1, r.method( :moves ).arity )
    assert_equal( -2, r.method( :apply ).arity )
    assert_equal( -2, r.method( :apply! ).arity )
    assert_equal(  0, r.method( :has_moves ).arity )
    assert_equal(  1, r.method( :has_moves? ).arity )
    assert_equal(  1, r.method( :censor ).arity )
    assert_equal(  0, r.method( :final? ).arity )
    assert_equal(  1, r.method( :winner? ).arity )
    assert_equal(  1, r.method( :loser? ).arity )
    assert_equal(  0, r.method( :draw? ).arity )
  end

  def test__dup
    srand 123456789  # We do random things, but should still be repeatable

    g = new_game
    30.times do                          # Take two steps forward,
      p = g.history.last.dup             # one step back, check for corruption
      break if g.final?
      pn = g.has_moves.first
      g[pn] << g[pn].moves[rand(g[pn].moves.size)] 
      assert_not_equal( p, g.undo.last )      
      assert_equal( p, g.history.last )
      break if g.final?
      pn = g.has_moves.first
      g[pn] << g[pn].moves[rand(g[pn].moves.size)] 
    end
  end

  def play_sequence( s )
    g = new_game
    g << s[0,s.size-1]
    assert( !g.final? )
    g << s[-1]
    assert( g.final? )
    assert( g.moves.empty? )
    assert( ! g.move?( s[-1] ) )
    assert( ! g.move?( nil ) )
    assert( g.has_moves.empty? )
    assert( g.instructions == "" )

    rules.players.each do |p|
      assert( g.moves( p ).empty? )
      assert( ! g.has_moves?( p ) )
    end

    g
  end

  def test__move?
    g = new_game

    assert( ! g.move?( nil ) )

    g.moves.each do |move|
      assert( g.move?( move ) )
      (g.player_names - g.has_moves).each { |p| assert( !g.move?( move, p ) ) }
    end

    g.has_moves.each do |p| 
      assert( ! g.move?( nil, p ) )
      g.moves( p ).each { |move| assert( g.move?( move, p ) ) }
    end

    g[g.has_moves.first] << g.moves( g.has_moves.first ).first

    g.moves.each do |move|
      assert( g.move?( move ) )
      (g.player_names - g.has_moves).each { |p| assert( !g.move?( move, p ) ) }
    end
  end

  def test__has_moves
    g = new_game
    10.times do

      g.has_moves.each do |p|
        assert( g.has_moves?( p ) )
        assert( g.history.last.has_moves?( p ) ) # There are two #has_moves?
      end

      (g.player_names - g.has_moves).each do |p|
        assert( ! g.has_moves?( p ) )
        assert( ! g.history.last.has_moves?( p ) )
        assert_equal( [], g.moves( p ) )
      end

      g[g.has_moves.first] << g[g.has_moves.first].moves.first
      break if g.final?
    end
  end

  def test__marshal
    g = new_game
    g2 = nil
    assert_nothing_raised { g2 = Marshal::load( Marshal::dump( g ) ) }
    #assert_equal( g, g2 ) #Game doesn't implement ==
    assert_equal( g.history.last, g2.history.last )
  end

  def test__yaml
    g = new_game
    g2 = nil
    assert_nothing_raised { g2 = YAML::load( YAML::dump( g ) ) }
    #assert_equal( g, g2 ) #Game doesn't implement ==
    assert_equal( g.history.last, g2.history.last )
  end

  def test__hash
    if rules.random?
      g1 = new_game( 1234 )
      g2 = new_game( 1234 )
    else
      g1 = new_game
      g2 = new_game
    end

    10.times do
      break if g1.final?

      pn = g1.has_moves.first
      g1[pn] << g1[pn].moves.first
      g2[pn] << g2[pn].moves.first

      assert( g1.history.last == g2.history.last )
      assert( g1.history.last.hash == g2.history.last.hash )
    end
  end

  def test__misere
    srand 1234

    unless rules.misere?
      misere_rules = Rules.create_misere( rules )

      if rules.score_determines_outcome?
        assert( misere_rules.score_determines_outcome? )
        assert_equal( rules.highest_score_determines_winner?,
                      misere_rules.lowest_score_determines_winner? )
        assert_equal( rules.lowest_score_determines_winner?,
                      misere_rules.highest_score_determines_winner? )
      end

      if rules.random?
        g = Game.new( rules, 1234 )
        mg = Game.new( misere_rules, 1234 )
      else
        g = Game.new( rules )
        mg = Game.new( misere_rules )
      end

      until g.final? || mg.final?
        g.has_moves.each do |p|
          m = g.moves( p )[rand( g.moves( p ).length )]

          assert( g.move?( m, p ) )
          assert( mg.move?( m, p ) )

          g[p]  << m
          mg[p] << m
        end
      end

      assert( g.final? )
      assert( mg.final? )

      assert_equal( g.draw?, mg.draw? )

      # At least one winner will now be a loser and vice versa.  Note that
      # in a game with 3 or more players it's possible for one or more
      # players to remain losers under both sets of rules.

      unless g.draw?
        assert( rules.players.any? { |p| g.winner?( p ) && mg.loser?( p ) } )
        assert( rules.players.any? { |p| g.loser?( p ) && mg.winner?( p ) } )
      end
    end
  end
end

