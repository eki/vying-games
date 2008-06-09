require 'test/unit'

require 'vying'

class TestGame < Test::Unit::TestCase
  def test_initialize
    g = Game.new TicTacToe
    assert_equal( TicTacToe, g.rules )
    assert_equal( [], g.sequence )
    assert_equal( History.new( TicTacToe.new ), g.history )
    assert_equal( Board.new( 3, 3 ), g.board )
    assert_equal( :x, g.turn )
    assert_equal( nil, g.seed )
    assert( ! g.respond_to?( :rng ) )

    g = Game.new Ataxx, 1234
    assert_equal( Ataxx, g.rules )
    assert_equal( [], g.sequence )
    assert_equal( History.new( Ataxx.new( 1234 ) ), g.history )
    assert_equal( :red, g.turn )
    assert_equal( 1234, g.seed )
    assert( g.respond_to?( :rng ) )
  end

  def test_censor
    g = Game.new Ataxx, 1234
    assert_equal( :hidden, g.censor( :red ).rng )
    assert_equal( :hidden, g.censor( :blue ).rng )
    assert_not_equal( :hidden, g.censor( :red ).board )
    assert_not_equal( :hidden, g.censor( :blue ).board )
  end

  def test_turn
    g = Game.new TicTacToe
    assert_equal( :x, g.turn )
    assert_equal( :x, g.turn( :now ) )
    assert_equal( :o, g.turn( :next ) )
    assert_equal( :o, g.turn( :rotate ) )
    assert_equal( :o, g.turn )
    assert_equal( :x, g.turn( :rotate ) )
    assert_equal( :x, g.turn )
    assert_equal( :o, g.turn( :next ) )
    assert_equal( :o, g.turn( :rotate ) )
    assert_equal( :o, g.turn )
  end

  def test_has_moves
    g = Game.new TicTacToe
    assert_equal( [:x], g.has_moves )
    g.turn( :rotate )
    assert_equal( [:o], g.has_moves )
    g.turn( :rotate )
    assert_equal( [:x], g.has_moves )
    g.turn( :rotate )
    assert_equal( [:o], g.has_moves )

    g = Game.new Footsteps
    assert_equal( [:left, :right], g.has_moves )
    g << g.moves( :left ).first
    assert_equal( [:right], g.has_moves )
    g << g.moves( :right ).first
    assert_equal( [:left, :right], g.has_moves )
    g << g.moves( :right ).first
    assert_equal( [:left], g.has_moves )
  end

  def test_moves
    g = Game.new TicTacToe

    move = g.moves.first

    g << move

    assert_equal( [move], g.sequence )
  end

  def test_forfeit
    g = Game.new TicTacToe

    g[:x] = Human.new "john_doe"
    g[:o] = RandomBot.new "randombot"

    moves = g.moves

    assert( !g.final? )
    assert( !g.draw? )

    assert( g.special_move?( "forfeit_by_x" ) )
    assert( g.special_move?( "forfeit_by_o" ) )

    g[:x] << "forfeit"
    g.step

    assert( g.final? )
    assert( !g.draw? )
    assert( !g.winner?( :x ) )
    assert( g.loser?( :x ) )
    assert( g.winner?( :o ) )
    assert( !g.loser?( :o ) )

    assert( g.moves.empty? )

    moves.each do |move|
      assert( ! g.move?( move ) )
    end

    assert_equal( "forfeit_by_x", g.sequence.last )
    assert_equal( "randombot (o) defeated john_doe (x) (forfeit by john_doe)",
                  g.description )
  end

  def test_forfeit_off_turn
    g = Game.new TicTacToe

    g[:x] = Human.new "john_doe"
    g[:o] = Human.new "jane_doe"

    assert( g.special_move?( "forfeit_by_x" ) )
    assert( g.special_move?( "forfeit_by_o" ) )

    g[:o] << "forfeit"

    assert( ! g[:x].ready? )
    assert(   g[:o].ready? )
    assert(   g.has_moves?( :x ) )
    assert( ! g.has_moves?( :o ) )
    
    g.step

    assert( g.final? )
    assert( g.forfeit? )
    assert_equal( :o, g.forfeit_by )
  end

  def test_draw_by_agreement_accept
    g = Game.new AmericanCheckers

    g[:red] = Human.new "john_doe"
    g[:white] = Human.new "jane_doe"

    moves = g.moves

    assert( !g.final? )
    assert( !g.draw? )

    assert( g.special_move?( "draw_offered_by_red" ) )
    assert( g.special_move?( "draw_offered_by_white" ) )

    g[:red] << "offer_draw"
    g.step

    assert( g.draw_offered? )
    assert_equal( :red, g.draw_offered_by )
    
    assert( g.moves.empty? )

    moves.each do |move|
      assert( ! g.move?( move ) )
    end

    assert( g.special_move?( "accept_draw", :white ) )
    assert( g.special_move?( "reject_draw", :white ) )
    assert( ! g.special_move?( "accept_draw", :red ) )
    assert( ! g.special_move?( "reject_draw", :red ) )

    assert_equal( ["accept_draw", "reject_draw"], 
                  g.special_moves( :white).sort )

    g[:white] << "accept_draw"
    g.step
    
    assert( ! g.draw_offered? )
    assert( g.draw_by_agreement? )

    assert( g.final? )
    assert( g.draw? )
    assert( !g.winner?( :red ) )
    assert( !g.loser?( :red ) )
    assert( !g.winner?( :white ) )
    assert( !g.loser?( :white ) )

    assert( g.moves.empty? )

    moves.each do |move|
      assert( ! g.move?( move ) )
    end

    assert_equal( "draw", g.sequence.last )
    assert_equal( 
      "john_doe (red) and jane_doe (white) played to a draw (by agreement)",
      g.description )
  end

  def test_draw_by_agreement_reject
    g = Game.new AmericanCheckers

    g[:red] = Human.new "john_doe"
    g[:white] = Human.new "jane_doe"

    moves = g.moves

    assert( !g.final? )
    assert( !g.draw? )

    assert( g.special_move?( "draw_offered_by_red" ) )
    assert( g.special_move?( "draw_offered_by_white" ) )

    g[:red] << "offer_draw"
    g.step

    assert( g.draw_offered? )
    assert_equal( :red, g.draw_offered_by )
    
    assert( g.moves.empty? )

    moves.each do |move|
      assert( ! g.move?( move ) )
    end

    assert( g.special_move?( "accept_draw", :white ) )
    assert( g.special_move?( "reject_draw", :white ) )
    assert( ! g.special_move?( "accept_draw", :red ) )
    assert( ! g.special_move?( "reject_draw", :red ) )

    assert_equal( ["accept_draw", "reject_draw"], 
                  g.special_moves( :white).sort )

    g[:white] << "reject_draw"
    g.step
    
    assert( ! g.draw_offered? )
    assert( ! g.draw_by_agreement? )

    assert( ! g.final? )

    assert( ! g.special_move?( "accept_draw" ) )
    assert( ! g.special_move?( "reject_draw" ) )

    moves.each do |move|
      assert( g.move?( move ) )
    end
  end

  def test_time_exceeded
    g = Game.new TicTacToe

    g[:x] = Human.new "john_doe"
    g[:o] = RandomBot.new "randombot"

    moves = g.moves

    assert( g.special_move?( "time_exceeded_by_x" ) )
    assert( g.special_move?( "time_exceeded_by_o" ) )

    g << "time_exceeded_by_x"

    assert( g.final? )
    assert( !g.draw? )
    assert( !g.winner?( :x ) )
    assert( g.loser?( :x ) )
    assert( g.winner?( :o ) )
    assert( !g.loser?( :o ) )

    assert( g.moves.empty? )

    moves.each do |move|
      assert( ! g.move?( move ) )
    end

    assert_equal( "randombot (o) defeated john_doe (x) (time exceeded)",
                  g.description )
  end

  def test_undo
    g = Game.new TicTacToe
    g[:x] = Human.new "john_doe"
    g[:o] = Human.new "jane_doe"

    assert_equal( 0, g.sequence.length )
    assert_equal( 1, g.history.length )

    move = g.moves.first
    g << move

    assert_equal( 1, g.sequence.length )
    assert_equal( 2, g.history.length )
    assert_equal( move, g.sequence.last )

    p, m = g.undo

    assert_equal( 0, g.sequence.length )
    assert_equal( 1, g.history.length )
    assert_equal( move, m )

    move = "forfeit_by_x"
    g << move

    assert_equal( 1, g.sequence.length )
    assert_equal( 2, g.history.length )
    assert_equal( move, g.sequence.last )
    
    p, m = g.undo

    assert_equal( 0, g.sequence.length )
    assert_equal( 1, g.history.length )
    assert_equal( move, m )
  end

  def test_undo_by_request
    g = Game.new TicTacToe
    g[:x] = Human.new "john_doe"
    g[:o] = Human.new "jane_doe"

    assert_equal( 0, g.sequence.length )
    assert_equal( 1, g.history.length )

    move = g.moves.first
    g << move

    assert_equal( 1, g.sequence.length )
    assert_equal( 2, g.history.length )
    assert_equal( move, g.sequence.last )

    assert( g.special_move?( "undo_requested_by_x" ) )
    assert( g.special_move?( "undo_requested_by_o" ) )

    g[:x] << "request_undo"
    g.step

    assert( g.undo_requested? )
    assert_equal( "undo_requested_by_x", g.sequence.last )
    assert_equal( :x, g.undo_requested_by )
    assert( g.undo_requested_by?( :x ) )
    assert_equal( [:o], g.has_moves )

    assert( g.special_move?( "accept_undo", :o ) )
    assert( g.special_move?( "reject_undo", :o ) )
    assert( ! g.special_move?( "accept_undo", :x ) )
    assert( ! g.special_move?( "reject_undo", :x ) )

    assert_equal( ["accept_undo", "reject_undo"],
                  g.special_moves( :o ).sort )

    g[:o] << "reject_undo"
    g.step

    assert_equal( 1, g.sequence.length )
    assert_equal( 2, g.history.length )
    assert_equal( move, g.sequence.last )

    g[:o] << "request_undo"
    g.step

    assert( g.undo_requested? )
    assert_equal( "undo_requested_by_o", g.sequence.last )
    assert_equal( :o, g.undo_requested_by )
    assert( g.undo_requested_by?( :o ) )
    assert_equal( [:x], g.has_moves )

    assert( g.special_move?( "accept_undo", :x ) )
    assert( g.special_move?( "reject_undo", :x ) )
    assert( ! g.special_move?( "accept_undo", :o ) )
    assert( ! g.special_move?( "reject_undo", :o ) )

    assert_equal( ["accept_undo", "reject_undo"],
                  g.special_moves( :x ).sort )

    g[:x] << "accept_undo"
    g.step

    assert( ! g.special_move?( "accept_undo" ) )
    assert( ! g.special_move?( "reject_undo" ) )

    assert_equal( 0, g.sequence.length )
    assert_equal( 1, g.history.length )
  end

  def test_special_moves_undo
    g = Game.new Connect6

    g << g.moves.first
    g << g.moves.first

    assert( g.special_move?( "undo" ) )
    assert( g.special_move?( "undo", :white ) )
    assert( ! g.special_move?( "undo_requested_by_white" ) )
    assert( ! g.special_move?( "undo_requested_by_black" ) )
    assert( ! g.special_move?( "undo_requested_by_white", :white ) )
    assert( ! g.special_move?( "undo_requested_by_black", :black ) )
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

  def test_who
    g = Game.new TicTacToe

    g[:x] = Human.new "john_doe"
    g[:o] = Human.new "jane_doe"

    assert_equal( :x, g.who?( :x ) )
    assert_equal( :o, g.who?( :o ) )

    assert_equal( nil, g.who?( nil ) )

    assert_equal( :x, g.who?( g[:x] ) )
    assert_equal( :o, g.who?( g[:o] ) )

    assert_equal( g.move?( g.moves( :x ), :x ),
                  g.move?( g.moves( g[:x] ), g[:x] ) )

    assert_equal( g.move?( g.moves( :o ), :o ),
                  g.move?( g.moves( g[:o] ), g[:o] ) )

    assert_equal( g.has_moves?( :x ), g.has_moves?( g[:x] ) )
    assert_equal( g.has_moves?( :o ), g.has_moves?( g[:o] ) )

    g = Game.new Othello

    g[:black] = Human.new "john_doe"
    g[:white] = Human.new "jane_doe"

    assert_equal( g.score( :black ), g.score( g[:black] ) )
    assert_equal( g.score( :white ), g.score( g[:white] ) )
  end

  def test_pie_rule
    g = Game.new Y
    g[:blue] = Human.new "john_doe"
    g[:red]  = Human.new "jane_doe"


    assert( ! g.special_move?( "swap" ) )

    g << g.moves.first

    assert( g.special_move?( "swap" ) )
    assert( g.special_move?( "swap", :red ) )
    assert( ! g.special_move?( "swap", :blue ) )

    g << "swap"

    assert( ! g.special_move?( "swap" ) )
    assert_equal( g.history[1], g.history.last )
    assert_equal( "swap", g.sequence.last )
    assert_equal( Human.new( "jane_doe" ), g[:blue] )
    assert_equal( Human.new( "john_doe" ), g[:red] )
  end

  def test_leave
    g = Game.new Othello

    assert( ! g.unrated? )

    assert( ! g.special_moves.include?( "black_leaves" ) )
    assert( ! g.special_moves.include?( "white_leaves" ) )
  
    g[:black] = Human.new "john_doe"
    g[:white] = Human.new "jane_doe"

    assert( ! g.special_moves.include?( "black_leaves" ) )
    assert( ! g.special_moves.include?( "white_leaves" ) )
  
    g.instance_variable_set( "@unrated", true )

    assert( g.unrated? )

    assert( g.special_moves.include?( "black_leaves" ) )
    assert( g.special_moves.include?( "white_leaves" ) )
  
    g << "black_leaves"

    assert_equal( nil, g[:black] )
    assert( ! g.special_moves.include?( "black_leaves" ) )
    assert( g.special_moves.include?( "white_leaves" ) )

    g[:black] = Human.new "dude"
  
    assert( g.special_moves.include?( "black_leaves" ) )
    assert( g.special_moves.include?( "white_leaves" ) )

    g << "white_leaves"
  
    assert_equal( nil, g[:white] )
    assert( g.special_moves.include?( "black_leaves" ) )
    assert( ! g.special_moves.include?( "white_leaves" ) )

  end

end

