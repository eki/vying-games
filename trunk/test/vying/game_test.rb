require 'test/unit'

require 'vying/rules'
require 'vying/game'
require 'vying/ai/bot'

class FakeRules < Rules

  attr_reader :fake_board, :fake_foo

  name "Fake Rules"

  random

  allow_draws_by_agreement

  players [:a, :b, :c]

  censor :a => [:fake_foo],
         :b => [:fake_board]

  def initialize( seed=nil )
    super

    @fake_board, @fake_foo = "edcba", "bar"
  end

  def move?( move, player=nil )
    move.to_s =~ /(r|s)/
  end

  def moves( player=nil )
    return [] if final?
    ['r','s']
  end

  def apply!( move )
    if move.to_s =~ /r/
      fake_board.succ!
    elsif move.to_s =~ /s/
      fake_board.squeeze!
    end
    self
  end

  def final?
    fake_board.length == 1
  end

  def winner?( player )
    final? && player != turn
  end

  def loser?( player )
    final? && player == turn
  end

  def draw?
    false
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

  def test_has_moves
    g = Game.new( FakeRules )
    assert_equal( [:a], g.has_moves )
    g.turn( :rotate )
    assert_equal( [:b], g.has_moves )
    g.turn( :rotate )
    assert_equal( [:c], g.has_moves )
    g.turn( :rotate )
    assert_equal( [:a], g.has_moves )
  end

  def test_moves
    g = Game.new( FakeRules )
    moves = g.moves

    assert_equal( "r", moves[0] )
    assert_equal( "s", moves[1] )

    g << moves[0]

    assert_equal( [moves[0]], g.sequence )
    assert_equal( "edcbb", g.fake_board )

    g << (move = g.moves[1])

    assert_equal( move, g.sequence.last )
    assert_equal( "edcb", g.fake_board )

    g << 'r'
    g << 's'

    assert_equal( "edc", g.fake_board )
  end

  def test_final
    g = Game.new( FakeRules ) # edcba
    g << g.moves[0] # edcbb
    assert( !g.final? )
    g << g.moves[1] # edcb
    assert( !g.final? )
    g << g.moves[0] # edcc
    assert( !g.final? )
    g << g.moves[1] # edc
    assert( !g.final? )
    g << g.moves[0] # edd
    assert( !g.final? )
    g << g.moves[1] # ed
    assert( !g.final? )
    g << g.moves[0] # ee
    assert( !g.final? )
    g << g.moves[1] # e
    assert( g.final? )
    assert( g.moves.empty? )
  end

  def test_forfeit
    g = Game.new( FakeRules )

    g.players.each do |p|
      g.register_users p => Human.new
    end 

    assert( !g.final? )
    assert( !g.draw? )

    g.players.each do |p|
      assert( !g.winner?( p ) )
      assert( !g.loser?( p ) )
    end 

    moves = g.moves
   
    g.user_map[g.players.first] << "forfeit"
    g.step

    assert( g.final? )
    assert( !g.draw? )
    assert( !g.winner?( g.players.first ) )
    assert( g.loser?( g.players.first ) )
    assert( g.winner?( g.players.last ) )
    assert( !g.loser?( g.players.last ) )

    assert( g.moves.empty? )

    moves.each do |move|
      assert( ! g.move?( move ) )
    end

    assert_equal( "forfeit_by_#{g.players.first}", g.sequence.last )
  end

  def test_human
    u = Human.new
    
    assert( ! u.accept_draw?( nil, nil, nil ) )

    u << "accept_draw"

    assert( u.accept_draw?( nil, nil, nil ) )
    assert( ! u.accept_draw?( nil, nil, nil ) )

    u << "blah"

    assert( ! u.accept_draw?( nil, nil, nil ) )
    assert_equal( "blah", u.select( nil, nil, nil ) )

    u << "offer_draw"

    assert( u.offer_draw?( nil, nil, nil ) )
    assert( ! u.offer_draw?( nil, nil, nil ) )

    u << "forfeit"

    assert( u.forfeit?( nil, nil, nil ) )
    assert( ! u.forfeit?( nil, nil, nil ) )
  end

  def test_draw
    g = Game.new FakeRules

    g.players.each do |p|
      g.register_users p => Human.new
    end 

    assert( !g.final? )
    assert( !g.draw? )

    g.players.each do |p|
      assert( !g.winner?( p ) )
      assert( !g.loser?( p ) )
    end 

    moves = g.moves
   
    g.user_map[g.players.first] << "offer_draw"

    g.players.each do |p|
      g.user_map[p] << "accept_draw"
    end 

    g.step

    assert_equal( g.players.first, g.draw_offered_by )

    g.step

    assert( g.final? )
    assert( g.draw? )
    assert( !g.winner?( g.players.first ) )
    assert( !g.loser?( g.players.first ) )
    assert( !g.winner?( g.players.last ) )
    assert( !g.loser?( g.players.last ) )

    assert( g.moves.empty? )

    moves.each do |move|
      assert( ! g.move?( move ) )
    end

    assert( ! g.user_map[g.players.first].queue.empty? )

    assert_equal( "draw", g.sequence.last )
  end
end

