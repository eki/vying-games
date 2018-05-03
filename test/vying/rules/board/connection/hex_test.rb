require_relative '../../../../test_helper'

class TestHex < Minitest::Test
  include RulesTests

  def rules
    Hex
  end

  def test_info
    assert_equal( "Hex", rules.name )
  end

  def test_players
    assert_equal( [:red,:blue], rules.new.players )
  end

  def test_initialize       # Need to be more thorough here
    g = Game.new( rules )
    assert_equal( :red, g.turn )
    assert_equal( 11, g.board.width )
  end

  def test_options
    assert_equal( 11, Hex.options[:board_size].default )
    assert_equal( (9..19).to_a, Hex.options[:board_size].values )

    assert_equal( 11, Hex.new.board.width )
    assert_equal( 11, Hex.new( :board_size => 11 ).board.width )
    assert_equal(  9, Hex.new( :board_size =>  9 ).board.width )
    assert_equal( 14, Hex.new( :board_size => 14 ).board.width )
    assert_equal( 19, Hex.new( :board_size => 19 ).board.width )

    assert_raises( RuntimeError ) { Hex.new( :board_size =>  8 ) }
    assert_raises( RuntimeError ) { Hex.new( :board_size => 20 ) }
  end

  def test_has_moves
    g = Game.new( rules )
    assert_equal( [:red], g.has_moves )
    g << g.moves.first
    assert_equal( [:blue], g.has_moves )
  end

  def test_sides_red
    g = Game.new( rules, :board_size => 9 )
    g << [:c1, :a3,
          :c2, :b3,
          :b4, :d2,
          :b5, :e1,
          :a6, :f1,
          :b6, :e2,
          :b7, :f2,
          :b8, :g2,
          :b9, :h2]

    assert_equal( 2, g.board.groups[:red].length )
    assert_equal( 2, g.board.groups[:blue].length )

    assert( ! g.final? )

    g << :c3

    assert_equal( 1, g.board.groups[:red].length )

    assert( g.final? )

    assert( g.winner?( :red ) )
    assert( g.loser?( :blue ) )
    assert( ! g.winner?( :blue ) )
    assert( ! g.loser?( :red ) )
    assert( ! g.draw? )
  end

  def test_sides_blue
    g = Game.new( rules, :board_size => 9 )
    g << [:c1, :a3,
          :c2, :b3,
          :b4, :d2,
          :b5, :e1,
          :a6, :f1,
          :b6, :e2,
          :b7, :f2,
          :b8, :g2,
          :b9, :h2,
          :a1, :i2,
          :a2 ]

    assert_equal( 3, g.board.groups[:red].length )
    assert_equal( 2, g.board.groups[:blue].length )

    assert( ! g.final? )

    g << :c3

    assert_equal( 1, g.board.groups[:blue].length )

    assert( g.final? )

    assert( g.winner?( :blue ) )
    assert( g.loser?( :red ) )
    assert( ! g.winner?( :red ) )
    assert( ! g.loser?( :blue ) )
    assert( ! g.draw? )
  end
end

