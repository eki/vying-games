require_relative '../../../../test_helper'

class TestNineMensMorris < Minitest::Test
  include RulesTests

  def rules
    NineMensMorris
  end

  def test_info
    assert_equal( "Nine Men's Morris", rules.name )
  end

  def test_players
    assert_equal( [:black,:white], rules.new.players )
  end

  def test_init
    g = Game.new( rules )

    b = Board.square( 7 )

    b[:a2,:a3,:a5,:a6,
      :b1,:c1,:e1,:f1,
      :b7,:c7,:e7,:f7,
      :g2,:g3,:g5,:g6,
      :b3,:b5,
      :c2,:e2,
      :c6,:e6,
      :f3,:f5] = :x
    b[:d4] = :X

    assert_equal( b, g.board )

    r = { :black => 9, :white => 9 }

    assert_equal( r, g.remaining )

    assert( g.instructions =~ /^Place/ )

    assert_equal( false, g.removing )

    assert_equal( :black, g.turn )
  end

  def test_has_score
    g = Game.new( rules )
    assert( g.has_score? )
  end

  def test_has_moves
    g = Game.new( rules )
    assert_equal( [:black], g.has_moves )
    g << g.moves.first
    assert_equal( [:white], g.has_moves )
  end

  def test_placement_phase
    g = Game.new( rules )

    g.remaining[:black] = 3
    g.remaining[:white] = 3

    until g.remaining[:white] == 0
      g.moves.each do |move|
        assert_nil( g.board[move] )
        assert_equal( 1, move.to_coords.length )
      end

      rp = g.remaining[g.history.last.turn]

      if rp > 1
        assert( g.instructions =~ /^Place one of your #{rp}/ )
      elsif rp == 1
        assert( g.instructions =~ /^Place your last/ )
      end

      # This test is a little flawed, if the moves fall out right we'd "capture"
      # which we don't want to do.
      g << g.moves.first
    end

    assert_equal( 3, g.board.count( :black ) )
    assert_equal( 3, g.board.count( :white ) )
    assert_equal( 18, g.board.empty_count )

    g.moves.each do |move|
      assert_equal( 2, move.to_coords.length )
      assert( g.instructions =~ /^Move/ )
    end
  end

  def test_removal_during_placement_phase
    g = Game.new( rules )

    g.remaining[:black] = 3
    g.remaining[:white] = 3

    g << ["a1", "d1", "a4", "d2", "a7"]

    assert_equal( :black, g.turn )
    assert( g.removing )
    assert( g.instructions =~ /^Remove/ )
    assert_equal( 2, g.moves.length )
    assert( g.move?( "d1" ) )
    assert( g.move?( "d2" ) )

    g << "d2"

    assert_equal( :white, g.turn )
    assert( ! g.removing )
    assert( g.move?( "d2" ) )
  end

  def test_movement_phase
    g = Game.new( rules )

    g.remaining[:black] = 0
    g.remaining[:white] = 0

    g.board[:a1,:a4,:a7,:g1,:g7] = :black
    g.board[:d1,:d2,:d3,:e4,:e5,:d6] = :white

    g.moves.each do |move|
      assert_equal( 2, move.to_coords.length )
    end

    assert_equal( :black, g.turn )

    g << "g1g4"

    assert_equal( :white, g.turn )
    assert_nil( g.board[:g1] )
    assert_equal( :black, g.board[:g4] )

    g.moves.each do |move|
      assert_equal( 2, move.to_coords.length )
    end

    g << "d3e3"

    assert_equal( :white, g.turn )
    assert_nil( g.board[:d3] )
    assert_equal( :white, g.board[:e3] )
    assert( g.removing )

    assert( g.move?( "g4" ) )
    assert( g.move?( "g7" ) )
    assert( ! g.move?( "a1" ) )
    assert( ! g.move?( "a4" ) )
    assert( ! g.move?( "a7" ) )

    g << "g4"

    assert_equal( :black, g.turn )
    assert_nil( g.board[:g4] )
    assert( ! g.removing )
    
    g.moves.each do |move|
      assert_equal( 2, move.to_coords.length )
    end

    g << "a4b4"

    assert_equal( :white, g.turn )
    assert_nil( g.board[:a4] )
    assert_equal( :black, g.board[:b4] )
    assert( ! g.removing )

    g.moves.each do |move|
      assert_equal( 2, move.to_coords.length )
    end

    g << "e3d3"

    assert_equal( :white, g.turn )
    assert_nil( g.board[:e3] )
    assert_equal( :white, g.board[:d3] )
    assert( g.removing )

    assert( g.move?( "g7" ) )
    assert( g.move?( "a1" ) )
    assert( g.move?( "b4" ) )
    assert( g.move?( "a7" ) )

    g << "b4"

    # Now leaving moving phase and entering flying phase for black

    assert_equal( :black, g.turn )
    assert_nil( g.board[:b4] )
    assert( ! g.removing )

    assert_equal( 3 * g.board.empty_count, g.moves.uniq.length )
    
    g.moves.each do |move|
      assert_equal( 2, move.to_coords.length )

      coords = move.to_coords

      assert_equal( :black, g.board[coords.first] )
      assert_nil( g.board[coords.last] )
    end

    g << "g7a4"

    assert_equal( :black, g.turn )
    assert_nil( g.board[:b4] )
    assert_equal( :black, g.board[:a4] )
    assert( g.removing )

    assert( g.move?( "d6" ) )
    assert( g.move?( "e4" ) )
    assert( g.move?( "e5" ) )
    assert( ! g.move?( "d1" ) )
    assert( ! g.move?( "d2" ) )
    assert( ! g.move?( "d3" ) )

    g << "d6"

    assert_equal( :white, g.turn )
    assert_nil( g.board[:d6] )
    assert( ! g.removing )
    
    g.moves.each do |move|
      assert_equal( 2, move.to_coords.length )
    end

    g << "d3e3"

    assert_equal( :white, g.turn )
    assert_nil( g.board[:d3] )
    assert_equal( :white, g.board[:e3] )
    assert( g.removing )

    assert( g.move?( "a1" ) )
    assert( g.move?( "a4" ) )
    assert( g.move?( "a7" ) )

    g << "a4"
    
    assert_equal( :black, g.history.last.turn )
    assert_nil( g.board[:a4] )
    assert( ! g.removing )

    assert( g.final? )
    assert_equal( [], g.moves )
    assert_equal( [], g.has_moves )
    assert( g.winner?( :white ) )
    assert( g.loser?( :black ) )
    assert( ! g.winner?( :black ) )
    assert( ! g.loser?( :white ) )
    assert( ! g.draw? )
    assert_equal( 7, g.score( :white ) )
    assert_equal( 4, g.score( :black ) )
  end
end

