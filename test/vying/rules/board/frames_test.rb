require_relative '../../../test_helper'

class TestFrames < Minitest::Test
  include RulesTests

  def rules
    Frames
  end

  def test_info
    assert_equal( "Frames", rules.name )
    assert( Frames.sealed_moves? )
  end

  def test_players
    assert_equal( [:black,:white], rules.new.players )
  end

  def test_initialize
    g = Game.new( rules )
    assert_equal( [:black, :white], g.has_moves )
    assert_equal( 19, g.board.width )
    assert_equal( 19, g.board.height )
    assert_equal( 19*19, g.board.empty_count )
  end

  def test_moves
    g = Game.new( rules )

    assert_equal( 19*19*2, g.moves.length )
    assert_equal( 19*19, g.moves( :black ).length )
    assert_equal( 19*19, g.moves( :white ).length )

    g.board.coords.each do |c|
      assert( g[:black].move?( c ) )
      assert( g[:white].move?( c ) )
      assert( g.move?( c, :black ) )
      assert( g.move?( c, :white ) )
    end

    g[:black] << "n9"

    assert_equal( [:white], g.has_moves )

    assert_equal( 19*19, g.moves.length )
    assert_equal( 0, g.moves( :black ).length )
    assert_equal( 19*19, g.moves( :white ).length )

    g[:white] << "i2"

    assert_equal( [:black, :white], g.has_moves )

    assert_equal( 19*19*2-4, g.moves.length )
    assert_equal( 19*19-2, g.moves( :black ).length )
    assert_equal( 19*19-2, g.moves( :white ).length )

    assert( ! g.move?( "black_n9" ) )
    assert( ! g.move?( "white_n9" ) )
    assert( ! g.move?( "black_i2" ) )
    assert( ! g.move?( "white_i2" ) )
  end

  def test_censor
    g = Game.new( rules )
    p = g.censor( :black )
    assert_equal( nil, p.sealed[:black] )
    assert_equal( nil, p.sealed[:white] )

    g.append( :a1, :white )

    p = g.censor( :black )
    assert_equal( nil, p.sealed[:black] )
    assert_equal( :hidden, p.sealed[:white] )

    g.append( :a1, :black )

    p = g.censor( :white )
    assert_equal( nil, p.sealed[:black] )
    assert_equal( nil, p.sealed[:white] )

    g.append( :c3, :black )

    p = g.censor( :white )
    assert_equal( :hidden, p.sealed[:black] )
    assert_equal( nil, p.sealed[:white] )

    g.append( :c3, :white )

    p = g.censor( :white )
    assert_equal( nil, p.sealed[:black] )
    assert_equal( nil, p.sealed[:white] )

    g.append( :d5, :white )

    p = g.censor( :white )
    assert_equal( nil, p.sealed[:black] )
    assert_equal( Coord[:d5], p.sealed[:white] )
  end
end

