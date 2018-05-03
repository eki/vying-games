require_relative '../../../test_helper'

class TestFootsteps < Minitest::Test
  include RulesTests

  def rules
    Footsteps
  end

  def test_info
    assert_equal( "Footsteps", rules.name )
    assert( rules.version > "1.0.0" )
    assert( rules.sealed_moves? )
  end

  def test_players
    assert_equal( [:left, :right], rules.new.players )
  end

  def test_init
    g = Game.new( rules )

    assert_equal( 3, g.marker )
    assert_equal( 50, g.points[:left] )
    assert_equal( 50, g.points[:right] )
    assert_nil( g.bids[:left] )
    assert_nil( g.bids[:right] )
    assert_equal( [], g.rounds )
  end

  def test_has_score
    g = Game.new( rules )
    assert( !g.has_score? )
  end

  def test_has_moves
    g = Game.new( rules )
    assert_equal( [:left, :right], g.has_moves )
    assert( g.has_moves.include?( g.turn ) )
    g.append( 1, :left )
    assert_equal( [:right], g.has_moves )
    assert( g.has_moves.include?( g.turn ) )
    g.append( 1, :right )
    assert_equal( [:left, :right], g.has_moves )
    assert( g.has_moves.include?( g.turn ) )
    g.append( 2, :right )
    assert_equal( [:left], g.has_moves )
    assert( g.has_moves.include?( g.turn ) )
  end

  def test_censor
    g = Game.new( rules )
    p = g.censor( :left )
    assert_nil( p.bids[:left] )
    assert_nil( p.bids[:right] )

    g.append( 10, :right )

    p = g.censor( :left )
    assert_nil( p.bids[:left] )
    assert_equal( :hidden, p.bids[:right] )

    p = g.censor( :right )
    assert_nil( p.bids[:left] )
    assert_equal( 10, p.bids[:right] )

    g.append( 5, :left )

    p = g.censor( :left )
    assert_nil( p.bids[:left] )
    assert_nil( p.bids[:right] )

    p = g.censor( :right )
    assert_nil( p.bids[:left] )
    assert_nil( p.bids[:right] )

    g.append( 4, :left )

    p = g.censor( :left )
    assert_equal( 4, p.bids[:left] )
    assert_nil( p.bids[:right] )

    p = g.censor( :right )
    assert_equal( :hidden, p.bids[:left] )
    assert_nil( p.bids[:right] )
  end

  def test_sealed_moves
    g = Game.new( rules )
   
    assert_equal( [],  g.sealed_moves( :left ) ) 
    assert_equal( [], g.sealed_moves( :right ) ) 
    assert_equal( [], g.sealed_moves( nil ) ) 

    assert_equal( [], g.history.censored_sequence( :left ) )
    assert_equal( [], g.history.censored_sequence( :right ) )
    assert_equal( [], g.history.censored_sequence( nil ) )

    g.append( 4, :left )

    assert_equal( [],  g.sealed_moves( :left ) ) 
    assert_equal( [4], g.sealed_moves( :right ) ) 
    assert_equal( [4], g.sealed_moves( nil ) ) 

    assert_equal( ["4"], g.history.censored_sequence( :left ) )
    assert_equal( [:hidden], g.history.censored_sequence( :right ) )
    assert_equal( [:hidden], g.history.censored_sequence( nil ) )

    g.append( 5, :right )

    assert_equal( [], g.sealed_moves( :left ) ) 
    assert_equal( [], g.sealed_moves( :right ) ) 
    assert_equal( [], g.sealed_moves( nil ) ) 

    assert_equal( ["4", "5"], g.history.censored_sequence( :left ) )
    assert_equal( ["4", "5"], g.history.censored_sequence( :right ) )
    assert_equal( ["4", "5"], g.history.censored_sequence( nil ) )

    g.append( 6, :right )

    assert_equal( [6], g.sealed_moves( :left ) ) 
    assert_equal( [],  g.sealed_moves( :right ) ) 
    assert_equal( [6], g.sealed_moves( nil ) ) 

    assert_equal( ["4", "5", :hidden], g.history.censored_sequence( :left ) )
    assert_equal( ["4", "5", "6"], g.history.censored_sequence( :right ) )
    assert_equal( ["4", "5", :hidden], g.history.censored_sequence( nil ) )

    g.append( 4, :left )

    assert_equal( [], g.sealed_moves( :left ) ) 
    assert_equal( [], g.sealed_moves( :right ) ) 
    assert_equal( [], g.sealed_moves( nil ) ) 

    assert_equal( ["4", "5", "6", "4"], g.history.censored_sequence( :left ) )
    assert_equal( ["4", "5", "6", "4"], g.history.censored_sequence( :right ) )
    assert_equal( ["4", "5", "6", "4"], g.history.censored_sequence( nil ) )

    g.append( 4, :left )

    assert_equal( [], g.sealed_moves( :left ) ) 
    assert_equal( [4], g.sealed_moves( :right ) ) 
    assert_equal( [4], g.sealed_moves( nil ) ) 


    assert_equal( ["4", "5", "6", "4", "4"], 
                  g.history.censored_sequence( :left ) )
    assert_equal( ["4", "5", "6", "4", :hidden], 
                  g.history.censored_sequence( :right ) )
    assert_equal( ["4", "5", "6", "4", :hidden], 
                  g.history.censored_sequence( nil ) )
  end

  def test_game01
    g = play_sequence( [Move.new( "50", :left ), Move.new( "40", :right ),
                        Move.new( "1", :right ), Move.new( "1", :right ),
                        Move.new( "1", :right ), Move.new( "1", :right )] )

    assert( !g.draw? )
    assert( !g.winner?( :left ) )
    assert( g.loser?( :left ) )
    assert( g.winner?( :right ) )
    assert( !g.loser?( :right ) )
  end

  def test_game02
    g = play_sequence( [Move.new( "10", :left ), Move.new( "9", :right ),
                        Move.new( "8", :right ), Move.new( "9", :left ),
                        Move.new( "2", :left ), Move.new( "1", :right )] )

    assert( !g.draw? )
    assert( g.winner?( :left ) )
    assert( !g.loser?( :left ) )
    assert( !g.winner?( :right ) )
    assert( g.loser?( :right ) )
  end

  def test_game03
    g = play_sequence( [Move.new( "10", :left ), Move.new( "9", :right ),
                        Move.new( "9", :right ), Move.new( "8", :left ),
                        Move.new( "20", :left ), Move.new( "20", :right ),
                        Move.new( "10", :right ), Move.new( "10", :left ),
                        Move.new( "1", :left ), Move.new( "1", :right ),
                        Move.new( "1", :left ), Move.new( "1", :right )] )

    assert( g.draw? )
    assert( !g.winner?( :left ) )
    assert( !g.loser?( :left ) )
    assert( !g.winner?( :right ) )
    assert( !g.loser?( :right ) )
  end

end

