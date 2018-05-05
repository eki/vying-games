# frozen_string_literal: true

require_relative '../../../../test_helper'

class TestHavannah < Minitest::Test
  include RulesTests

  def rules
    Havannah
  end

  def test_info
    assert_equal('Havannah', rules.name)
  end

  def test_players
    assert_equal([:blue, :red], rules.new.players)
  end

  # Need to be more thorough here
  def test_initialize
    g = Game.new(rules)
    assert_equal(:blue, g.turn)
  end

  def test_has_moves
    g = Game.new(rules)
    assert_equal([:blue], g.has_moves)
    g << g.moves.first
    assert_equal([:red], g.has_moves)
  end

  def test_bridge_01
    g = play_sequence %w(s10 a1 r10 a2 r11 b2 r12 b3
                       r13 c1 r14 c2 r15 d2 r16 d3
                       r17 e1 r18 e3 s19)

    assert(!g.draw?)
    assert(g.winner?(:blue))
    assert(!g.loser?(:blue))
    assert(!g.winner?(:red))
    assert(g.loser?(:red))
  end

  def test_bridge_02
    g = play_sequence %w(s10 a1 s11 a2 s12 b2 s13 b3
                       s14 c1 s15 c2 s16 d2 s17 d3
                       s18 e1 s19)

    assert(!g.draw?)
    assert(g.winner?(:blue))
    assert(!g.loser?(:blue))
    assert(!g.winner?(:red))
    assert(g.loser?(:red))
  end

  def test_fork_01
    g = play_sequence %w(s18 a1 r19 a2 r18 b2 q17 b3
                       p16 c1 o15 c2 n14 d2 n13 d3
                       n12 e1 n11 e3 n10 e4 n9 e5
                       n8 f1 n7 f3 n6 f5 n5)

    assert(!g.draw?)
    assert(g.winner?(:blue))
    assert(!g.loser?(:blue))
    assert(!g.winner?(:red))
    assert(g.loser?(:red))
  end

  def test_fork_02
    g = play_sequence %w(s18 a1 s19 a2 r18 b2 q17 b3
                       p16 c1 o15 c2 n14 d2 n13 d3
                       n12 e1 n11 e3 n10 e4 n9 e5
                       n8 f1 n7 f3 n6 f5 n5 f6
                       r19)

    assert(!g.draw?)
    assert(g.winner?(:blue))
    assert(!g.loser?(:blue))
    assert(!g.winner?(:red))
    assert(g.loser?(:red))
  end

  def test_ring_01
    g = play_sequence %w(d6 j11 c5 j10 c4 j9
                       d4 j8 e5 j7 e6)

    assert(!g.draw?)
    assert(g.winner?(:blue))
    assert(!g.loser?(:blue))
    assert(!g.winner?(:red))
    assert(g.loser?(:red))
  end

  def test_ring_02
    g = play_sequence %w(b6 j11 a5 j10 c6 j9
                       b4 j8 c5 j7 a4)

    assert(!g.draw?)
    assert(g.winner?(:blue))
    assert(!g.loser?(:blue))
    assert(!g.winner?(:red))
    assert(g.loser?(:red))
  end

  def test_filled_ring_01
    g = play_sequence %w(p16 o8 q17 o9 r18 o10 r17 o11
                       q16 o12 q18 o13 p17)

    assert(!g.draw?)
    assert(g.winner?(:blue))
    assert(!g.loser?(:blue))
    assert(!g.winner?(:red))
    assert(g.loser?(:red))
  end

  def test_filled_ring_02
    g = play_sequence %w(p17 q17 p16 o9 r18 o10 r17 o11
                       q16 o12 q18)

    assert(!g.draw?)
    assert(g.winner?(:blue))
    assert(!g.loser?(:blue))
    assert(!g.winner?(:red))
    assert(g.loser?(:red))
  end

  def test_filled_ring_03
    g = Game.new rules

    g << %w(s19 o8 s18 o9 r18 o10
          r19 o11 q18 o12 q19)

    assert_equal(1, g.board.groups[:blue].length)
    assert(!g.final?)
  end

  def test_draw
    g = play_sequence %w(a1 b1 c1 d1 e1 f1 g1 h1 i1
                       j1 a2 b2 c2 d2 e2 f2 g2 h2
                       i2 j2 k2 a3 b3 c3 d3 e3 f3
                       g3 h3 i3 j3 k3 l3 a4 b4 c4
                       d4 e4 f4 g4 h4 i4 j4 k4 l4
                       m4 a5 b5 c5 d5 e5 f5 g5 h5
                       i5 j5 k5 l5 m5 n5 a6 b6 c6
                       d6 e6 f6 g6 h6 i6 j6 k6 l6
                       m6 n6 o6 a7 b7 c7 d7 e7 f7
                       g7 h7 i7 j7 k7 l7 m7 n7 o7
                       p7 a8 b8 c8 d8 e8 f8 g8 h8
                       i8 j8 k8 l8 m8 n8 o8 p8 q8
                       a9 b9 c9 d9 e9 f9 g9 h9 i9
                       j9 k9 l9 m9 n9 o9 p9 q9 r9
                       a10 b10 c10 d10 e10 f10 g10 h10
                       i10 j10 k10 l10 m10 n10 o10 p10
                       q10 r10 s10 b11 c11 d11 e11 f11
                       g11 h11 i11 j11 k11 l11 m11 n11
                       o11 p11 q11 r11 s11 c12 d12 e12
                       f12 g12 h12 i12 j12 k12 l12 m12
                       n12 o12 p12 q12 r12 s12 d13 e13
                       f13 g13 h13 i13 j13 k13 l13 m13
                       n13 o13 p13 q13 r13 s13 e14 f14
                       g14 h14 i14 j14 k14 l14 m14 n14
                       o14 p14 q14 r14 s14 f15 g15 h15
                       i15 j15 k15 l15 m15 n15 o15 p15
                       q15 r15 s15 g16 h16 i16 j16 k16
                       l16 m16 n16 o16 p16 q16 r16 s16
                       h17 i17 j17 k17 l17 m17 n17 o17
                       p17 q17 r17 s17 i18 j18 k18 l18
                       m18 n18 o18 p18 q18 r18 s18 j19
                       k19 l19 m19 n19 o19 p19 q19 r19
                       s19)
    assert(g.draw?)
    assert(!g.winner?(:blue))
    assert(!g.loser?(:blue))
    assert(!g.winner?(:red))
    assert(!g.loser?(:red))
  end

end
