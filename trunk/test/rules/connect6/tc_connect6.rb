
require "test/unit"
require "rules/connect6/connect6"

class TestConnect6 < Test::Unit::TestCase
  def test_init
    g = Game.new( Connect6 )
    assert_equal( Board.new( 19, 19 ), g.board )
    assert_equal( Player.black, g.turn )
    assert_equal( 19*19, g.unused_ops.length )
    assert_equal( 'a0', g.unused_ops.first )
    assert_equal( 's18', g.unused_ops.last )
  end

  def test_ops
    g = Game.new( Connect6 )
    ops = g.ops

    assert_equal( 'a0', ops[0] )
    assert_equal( 'b0', ops[1] )
    assert_equal( 'c0', ops[2] )
    assert_equal( 'd0', ops[3] )
    assert_equal( 'e0', ops[4] )
    assert_equal( 'f0', ops[5] )
    assert_equal( 'g0', ops[6] )
    assert_equal( 's18', ops[19*19-1] )

    while ops = g.ops do
      g << ops[0]
    end

    assert_not_equal( g.history[0], g.history.last )

    assert_equal( 19*19-(19*5+6), g.board.count( nil ) )
    assert_equal( (19*5-1)/2+4, g.board.count( Piece.black ) )
    assert_equal( (19*5-1)/2+3, g.board.count( Piece.white ) )
  end

  def test_players
    g = Game.new( Connect6 )
    assert_equal( [Player.black,Player.white], g.players )
    assert_equal( [Piece.black,Piece.white], g.players )
  end

  def test_game01
    # This game is going to be a win for White (vertical)
    g = Game.new( Connect6 )
    g << "b0" << "f13" << "f12" << "b1" << "b2" << "f11" << "f10" <<
         "b3" << "b4"  << "f9"
    assert( !g.final? )
    g << "f8"
    assert( g.final? )

    assert( !g.draw? )
    assert( !g.winner?( Player.black ) )
    assert( g.loser?( Player.black ) )
    assert( g.winner?( Player.white ) )
    assert( !g.loser?( Player.white ) )

    assert_equal( -1, g.score( Player.black ) )
    assert_equal( 1, g.score( Player.white ) )
  end

  def test_game02
    # This game is going to be a win for White (diagonal)(winner in middle)
    g = Game.new( Connect6 )
    g << "f12" << "a0" << "c2" << "f11" << "f10" << "d3" << "e4" <<
         "f13" << "f9" << "f5"
    assert( !g.final? )
    g << "b1"
    assert( g.final? )

    assert( !g.draw? )
    assert( !g.winner?( Player.black ) )
    assert( g.loser?( Player.black ) )
    assert( g.winner?( Player.white ) )
    assert( !g.loser?( Player.white ) )

    assert_equal( -1, g.score( Player.black ) )
    assert_equal( 1, g.score( Player.white ) )
  end

  def test_game03
    # This game is going to be a win for Black (horizontal)(7-in-a-row)
    g = Game.new( Connect6 )
    g << "a0" << "f9" << "f8" << "b0" << "c0" << "g9" << "g8" <<
         "e0" << "f0" << "g7" << "g6" << "g0"
    assert( !g.final? )
    g << "d0"
    assert( g.final? )

    assert( !g.draw? )
    assert( g.winner?( Player.black ) )
    assert( !g.loser?( Player.black ) )
    assert( !g.winner?( Player.white ) )
    assert( g.loser?( Player.white ) )

    assert_equal( 1, g.score( Player.black ) )
    assert_equal( -1, g.score( Player.white ) )
  end

  def test_game04
    # This game is going to be a draw
    g = Game.new( Connect6 )

    # This draw was generated (this is a very difficult game to intentionally
    # draw!  This hasn't been gone over in a ton of details, but appears to
    # be correct.
    sequence = ["j15", "g2", "h7", "c3", "h13", "p4", "h11", "h8", "b0", "d15",
                "h1", "o1", "n13", "h10", "g5", "m16", "c16", "k16", "b13",
                "m10", "j5", "e0", "e2", "m2", "f6", "q0", "j6", "k12", "a4",
                "g18", "g14", "h15", "r13", "j18", "a0", "k8", "l1", "i6",
                "p3", "s5", "m18", "e12", "l12", "i17", "m11", "s8", "a5",
                "d4", "l3", "m4", "b18", "p12", "m3", "b17", "k4", "r10", "n9",
                "o15", "a6", "k6", "k3", "d6", "c17", "r14", "d14", "k5", "g6",
                "i3", "b8", "s14", "b16", "i1", "j4", "m12", "l8", "q3", "h18",
                "b11", "f5", "o2", "s10", "p17", "o18", "r5", "c0", "q13",
                "l9", "f2", "r3", "e7", "g0", "e1", "i13", "r9", "f9", "q4",
                "l7", "k17", "f15", "n12", "l4", "p11", "c15", "d7", "r4",
                "h2", "a3", "q17", "q15", "i10", "k0", "c5", "i2", "j7", "n8",
                "b6", "p9", "c14", "f12", "q14", "p0", "m8", "n5", "k11",
                "g10", "a17", "a18", "i7", "d12", "p13", "m14", "o9", "a16",
                "g16", "p16", "p7", "j12", "p8", "k1", "l13", "d3", "h12",
                "c4", "a13", "k7", "i5", "l5", "r0", "n10", "o7", "h3", "c1",
                "l10", "o6", "p18", "n18", "c10", "j9", "i14", "q8", "s1",
                "m17", "b1", "e3", "s11", "c8", "m9", "j1", "f11", "e8", "f18",
                "s13", "i0", "s17", "o12", "n0", "i12", "k14", "j0", "l2",
                "b9", "q6", "b10", "g7", "b5", "j10", "q10", "f13", "a1", "a10",
                "o11", "e14", "i9", "r1", "p5", "s16", "c9", "r15", "k2", "c18",
                "e11", "f7", "p10", "e10", "n6", "j2", "l0", "e13", "f14",
                "l15", "d8", "r11", "r6", "d18", "f8", "s15", "r2", "c2", "o8",
                "h17", "j17", "d0", "s7", "o14", "e17", "b7", "h16", "n4",
                "f4", "l6", "d11", "l17", "q11", "p1", "o13", "m15", "e4",
                "g15", "f16", "g17", "c13", "q16", "d16", "e16", "a14", "f10",
                "e5", "o5", "d17", "s3", "m13", "q12", "g12", "e15", "h0",
                "a2", "r17", "p2", "j13", "i16", "i4", "g4", "n2", "i11", "s6",
                "q7", "n11", "n7", "c11", "a12", "n15", "d9", "a15", "r8",
                "f3", "r16", "g13", "n3", "g8", "i15", "s9", "s2", "k9", "j3",
                "m6", "b12", "o16", "n17", "c6", "m5", "f0", "g3", "r12",
                "s12", "q9", "g9", "k18", "l14", "r7", "e6", "p6", "h6", "o0",
                "q18", "q1", "f17", "d5", "d1", "b2", "l11", "n1", "j11", "h4",
                "a7", "e9", "h9", "b4", "n16", "c7", "q2", "a11", "q5", "b14",
                "i18", "m1", "p15", "j8", "a8", "s18", "l18", "k13", "p14",
                "c12", "s4", "d10", "o3", "g11", "m7", "d2", "b3", "n14",
                "l16", "j16", "o10", "o17", "g1", "k15", "a9", "o4", "m0",
                "f1", "h5", "i8", "s0", "j14", "e18", "k10", "r18", "d13",
                "h14", "b15"]

    sequence.each { |op| g << op }
    
    assert( g.final? )

    assert( g.draw? )
    assert( !g.winner?( Player.black ) )
    assert( !g.loser?( Player.black ) )
    assert( !g.winner?( Player.white ) )
    assert( !g.loser?( Player.white ) )

    assert_equal( 0, g.score( Player.black ) )
    assert_equal( 0, g.score( Player.white ) )
  end

end

