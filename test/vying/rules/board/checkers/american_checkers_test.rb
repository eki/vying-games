require 'test/unit'

require 'vying'
require 'vying/rules/rules_test'

class TestAmericanCheckers < Test::Unit::TestCase
  include RulesTests

  def rules
    AmericanCheckers
  end

  def test_info
    assert_equal( "American Checkers", rules.name )
  end

  def test_players
    assert_equal( [:red,:white], rules.new.players )
  end

  def test_init
    g = Game.new( rules )

    b = Board.new( :shape => :square, :length => 8 )

    b[:b1,:d1,:f1,:h1,:a2,:c2,:e2,:g2,:b3,:d3,:f3,:h3] = :red
    b[:a8,:c8,:e8,:g8,:b7,:d7,:f7,:h7,:a6,:c6,:e6,:g6] = :white

    assert_equal( b, g.board )

    assert_equal( :red, g.turn )
    assert_equal( false, g.jumping )
  end

  def test_allow_draws_by_agreement
    g = Game.new( rules )
    assert( g.allow_draws_by_agreement? )
  end

  def test_has_score
    g = Game.new( rules )
    assert( g.has_score? )
  end

  def test_has_moves
    g = Game.new( rules )
    assert_equal( [:red], g.has_moves )
    g << g.moves.first
    assert_equal( [:white], g.has_moves )
  end

  def test_moves
    g = Game.new( rules )
    moves = g.moves

    assert_equal( 'b3c4', moves[0] )
    assert_equal( 'b3a4', moves[1] )
    assert_equal( 'd3e4', moves[2] )
    assert_equal( 'd3c4', moves[3] )
    assert_equal( 'f3g4', moves[4] )
    assert_equal( 'f3e4', moves[5] )
    assert_equal( 'h3g4', moves.last )

    g << g.moves.first until g.final?

    assert_not_equal( g.history.first, g.history.last )
  end

  def test_move_diagonal
    g = Game.new( rules )

    assert_equal( :red, g.board[:b3] )
    assert_equal( nil,  g.board[:c4] )

    g << "b3c4"

    assert_equal( nil,  g.board[:b3] )
    assert_equal( :red, g.board[:c4] )

    assert_equal( :white, g.board[:g6] )
    assert_equal( nil,    g.board[:h5] )

    g << "g6h5"
    
    assert_equal( nil,    g.board[:g6] )
    assert_equal( :white, g.board[:h5] )
  end

  def test_jumping
    g = Game.new( rules )

    g.board[:g4] = :white
    g.board[:f7] = nil

    assert_equal( ["f3h5", "h3f5"], g.moves )

    g << "f3h5"

    assert_equal( :red, g.turn )
    assert( g.jumping )
    assert_equal( ["h5f7"], g.moves )

    g << "h5f7"

    assert_equal( :white, g.turn )
    assert( ! g.jumping )
    assert_equal( ["e8g6"], g.moves )

    g << "e8g6"

    assert_equal( :red, g.turn )
    assert( ! g.jumping )
  end

  def test_jumping_to_king
    g = Game.new( rules )

    g.board[:c6] = :red
    g.board[:g6,:e8] = nil

    assert_equal( ["c6e8"], g.moves )
    
    g << "c6e8"

    assert_equal( :white, g.turn )
    assert( ! g.jumping )
    assert_equal( :RED_KING, g.board[:e8] )
    
    g << "a6b5"

    assert_equal( :red, g.turn )
    assert( ! g.jumping )
    assert_equal( ["e8g6"], g.moves )

    g << "e8g6"

    assert_equal( :white, g.turn )
    assert( ! g.jumping )
    assert_equal( ["h7f5"], g.moves )

    g << "h7f5"

    assert_equal( nil, g.board[:g6] )
  end

  def test_move_to_king
    g = Game.new( rules )

    g.board[:b1] = nil
    g.board[:a2] = :white
    g.rotate_turn

    g << "a2b1"

    assert_equal( :WHITE_KING, g.board[:b1] )
  end

  def test_jumping_backwards
    g = Game.new( rules )

    g.board[:c8] = :RED_KING
    g.board[:e6] = nil
    g.board[:d5] = :white

    assert_equal( ["c8e6"], g.moves )

    g << "c8e6"

    assert_equal( :red, g.turn )
    assert_equal( ["e6c4"], g.moves )
    assert( g.jumping )

    g << "e6c4"

    assert_equal( :white, g.turn )
    assert( !g.jumping )
  end

  def test_final_01
    g = Game.new( rules )

    g.board[:b1,:d1,:f1,:h1,:a2,:c2,:e2,:g2,:b3,:d3,:f3] = nil

    assert( !g.final? )

    g.board[:h3] = nil

    g.clear_cache

    assert( g.final? )
    assert( g.winner?( :white ) )
    assert( g.loser?( :red ) )
    assert( ! g.winner?( :red ) )
    assert( ! g.loser?( :white ) )
    assert( ! g.draw? )
  end

  def test_final_02
    g = Game.new( rules )

    g.board[:a8,:c8,:e8,:g8,:b7,:d7,:f7,:h7,:a6,:c6,:e6,:g6] = nil

    assert( !g.final? )

    g << g.moves.first

    assert( g.final? )
    assert( g.winner?( :red ) )
    assert( g.loser?( :white ) )
    assert( ! g.winner?( :white ) )
    assert( ! g.loser?( :red ) )
    assert( ! g.draw? )
  end

  def test_final_03
    g = Game.new( rules )

    # Clear board
    g.board[:b1,:d1,:f1,:h1,:a2,:c2,:e2,:g2,:b3,:d3,:f3,:h3] = nil
    g.board[:a8,:c8,:e8,:g8,:b7,:d7,:f7,:h7,:a6,:c6,:e6,:g6] = nil

    # Reset it, white is wedged
    g.board[:b1] = :WHITE_KING
    g.board[:a2,:c2,:b3] = :white
    g.board[:d1,:f7] = :red

    assert( !g.final? )

    g << "f7e8"

    assert( g.final? )
    assert( g.winner?( :red ) )
    assert( g.loser?( :white ) )
    assert( ! g.winner?( :white ) )
    assert( ! g.loser?( :red ) )
    assert( ! g.draw? )
  end

end

