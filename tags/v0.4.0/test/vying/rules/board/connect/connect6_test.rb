require 'test/unit'

require 'vying'
require 'vying/rules/rules_test'

class TestConnect6 < Test::Unit::TestCase
  include RulesTests

  def rules
    Connect6
  end

  def test_info
    assert_equal( "Connect6", Connect6.info[:name] )
  end

  def test_players
    assert_equal( [:black,:white], Connect6.players )
    assert_equal( [:black,:white], Connect6.new.players )
  end

  def test_init
    g = Game.new( Connect6 )
    assert_equal( Board.new( 19, 19 ), g.board )
    assert_equal( :black, g.turn )
    assert_equal( 19*19, g.unused_moves.length )
    assert_equal( 'a1', g.unused_moves.first )
    assert_equal( 's19', g.unused_moves.last )
  end

  def test_has_score
    g = Game.new( Connect6 )
    assert( !g.has_score? )
  end

  def test_has_moves
    g = Game.new( Connect6 )
    assert_equal( [:black], g.has_moves )
    g << g.moves.first
    assert_equal( [:white], g.has_moves )
  end

  def test_moves
    g = Game.new( Connect6 )
    moves = g.moves

    assert_equal( 'a1', moves[0] )
    assert_equal( 'b1', moves[1] )
    assert_equal( 'c1', moves[2] )
    assert_equal( 'd1', moves[3] )
    assert_equal( 'e1', moves[4] )
    assert_equal( 'f1', moves[5] )
    assert_equal( 'g1', moves[6] )
    assert_equal( 's19', moves[19*19-1] )

    g << g.moves.first until g.final?

    assert_not_equal( g.history[0], g.history.last )

    assert_equal( 19*19-(19*5+6), g.board.empty_count )
    assert_equal( (19*5-1)/2+4, g.board.count( :black ) )
    assert_equal( (19*5-1)/2+3, g.board.count( :white ) )
  end

  def test_game01
    # This game is going to be a win for White (vertical)
    g = play_sequence( [:b1,:f14,:f13,:b2,:b3,:f12,:f11,:b4,:b5,:f10,:f9] )

    assert( !g.draw? )
    assert( !g.winner?( :black ) )
    assert( g.loser?( :black ) )
    assert( g.winner?( :white ) )
    assert( !g.loser?( :white ) )
  end

  def test_game02
    # This game is going to be a win for White (diagonal)(winner in middle)
    g = play_sequence( [:f13,:a1,:c3,:f12,:f11,:d4,:e5,:f14,:f10,:f6,:b2] )

    assert( !g.draw? )
    assert( !g.winner?( :black ) )
    assert( g.loser?( :black ) )
    assert( g.winner?( :white ) )
    assert( !g.loser?( :white ) )
  end

  def test_game03
    # This game is going to be a win for Black (horizontal)(7-in-a-row)
    g = play_sequence [:a1,:f10,:f9,:b1,:c1,:g10,:g9,:e1,:f1,:g8,:g7,:g1,:d1]

    assert( !g.draw? )
    assert( g.winner?( :black ) )
    assert( !g.loser?( :black ) )
    assert( !g.winner?( :white ) )
    assert( g.loser?( :white ) )
  end

  def test_game04
    # This draw was generated (this is a very difficult game to intentionally
    # draw!  This hasn't been gone over in a ton of detail, but appears to
    # be correct.
    s =  ["j16", "g3", "h8", "c4", "h14", "p5", "h12", "h9", "b1", "d16",
          "h2", "o2", "n14", "h11", "g6", "m17", "c17", "k17", "b14",
          "m11", "j6", "e1", "e3", "m3", "f7", "q1", "j7", "k13", "a5",
          "g19", "g15", "h16", "r14", "j19", "a1", "k9", "l2", "i7",
          "p4", "s6", "m19", "e13", "l13", "i18", "m12", "s9", "a6",
          "d5", "l4", "m5", "b19", "p13", "m4", "b18", "k5", "r11", "n10",
          "o16", "a7", "k7", "k4", "d7", "c18", "r15", "d15", "k6", "g7",
          "i4", "b9", "s15", "b17", "i2", "j5", "m13", "l9", "q4", "h19",
          "b12", "f6", "o3", "s11", "p18", "o19", "r6", "c1", "q14",
          "l10", "f3", "r4", "e8", "g1", "e2", "i14", "r10", "f10", "q5",
          "l8", "k18", "f16", "n13", "l5", "p12", "c16", "d8", "r5",
          "h3", "a4", "q18", "q16", "i11", "k1", "c6", "i3", "j8", "n9",
          "b7", "p10", "c15", "f13", "q15", "p1", "m9", "n6", "k12",
          "g11", "a18", "a19", "i8", "d13", "p14", "m15", "o10", "a17",
          "g17", "p17", "p8", "j13", "p9", "k2", "l14", "d4", "h13",
          "c5", "a14", "k8", "i6", "l6", "r1", "n11", "o8", "h4", "c2",
          "l11", "o7", "p19", "n19", "c11", "j10", "i15", "q9", "s2",
          "m18", "b2", "e4", "s12", "c9", "m10", "j2", "f12", "e9", "f19",
          "s14", "i1", "s18", "o13", "n1", "i13", "k15", "j1", "l3",
          "b10", "q7", "b11", "g8", "b6", "j11", "q11", "f14", "a2", "a11",
          "o12", "e15", "i10", "r2", "p6", "s17", "c10", "r16", "k3", "c19",
          "e12", "f8", "p11", "e11", "n7", "j3", "l1", "e14", "f15",
          "l16", "d9", "r12", "r7", "d19", "f9", "s16", "r3", "c3", "o9",
          "h18", "j18", "d1", "s8", "o15", "e18", "b8", "h17", "n5",
          "f5", "l7", "d12", "l18", "q12", "p2", "o14", "m16", "e5",
          "g16", "f17", "g18", "c14", "q17", "d17", "e17", "a15", "f11",
          "e6", "o6", "d18", "s4", "m14", "q13", "g13", "e16", "h1",
          "a3", "r18", "p3", "j14", "i17", "i5", "g5", "n3", "i12", "s7",
          "q8", "n12", "n8", "c12", "a13", "n16", "d10", "a16", "r9",
          "f4", "r17", "g14", "n4", "g9", "i16", "s10", "s3", "k10", "j4",
          "m7", "b13", "o17", "n18", "c7", "m6", "f1", "g4", "r13",
          "s13", "q10", "g10", "k19", "l15", "r8", "e7", "p7", "h7", "o1",
          "q19", "q2", "f18", "d6", "d2", "b3", "l12", "n2", "j12", "h5",
          "a8", "e10", "h10", "b5", "n17", "c8", "q3", "a12", "q6", "b15",
          "i19", "m2", "p16", "j9", "a9", "s19", "l19", "k14", "p15",
          "c13", "s5", "d11", "o4", "g12", "m8", "d3", "b4", "n15",
          "l17", "j17", "o11", "o18", "g2", "k16", "a10", "o5", "m1",
          "f2", "h6", "i9", "s1", "j15", "e19", "k11", "r19", "d14",
          "h15", "b16"]

    g = play_sequence s

    assert( g.draw? )
    assert( !g.winner?( :black ) )
    assert( !g.loser?( :black ) )
    assert( !g.winner?( :white ) )
    assert( !g.loser?( :white ) )
  end

end

