
require 'test/unit'
require 'vying'

class TestGame < Test::Unit::TestCase
  def test_initialize
    g = Game.new TicTacToe
    assert_equal( TicTacToe, g.rules )
    assert_equal( [], g.sequence )
    assert_equal( History.new( TicTacToe, nil, TicTacToe.options ), g.history )
    assert_equal( Board.new( 3, 3 ), g.board )
    assert_equal( :x, g.turn )
    assert_equal( nil, g.seed )
    assert( ! g.rng )

    return unless Vying::RandomSupport

    g = Game.new Ataxx, 1234
    assert_equal( Ataxx, g.rules )
    assert_equal( [], g.sequence )
    assert_equal( History.new( Ataxx, 1234, Ataxx.options ), g.history )
    assert_equal( :red, g.turn )
    assert_equal( 1234, g.seed )
    assert( g.respond_to?( :rng ) )
  end

  def test_replay
    g = Game.new TicTacToe

    g2 = Game.replay( g )

    assert_equal( g.history, g2.history )  # Game doesn't define ==
                                           # so we can only check history
    until g.final?
      g << g.moves.first
      g2 = Game.replay( g )
      assert_equal( g.history, g2.history )
    end
  end

  def test_censor
    return unless Vying::RandomSupport

    g = Game.new Ataxx, 1234
    assert_equal( :hidden, g.censor( :red ).rng )
    assert_equal( :hidden, g.censor( :blue ).rng )
    assert_not_equal( :hidden, g.censor( :red ).board )
    assert_not_equal( :hidden, g.censor( :blue ).board )
  end

  def test_turn
    g = Game.new TicTacToe
    assert_equal( :x, g.turn )
    assert_equal( :o, g.next_turn )
    assert_equal( :o, g.rotate_turn )
    assert_equal( :o, g.turn )
    assert_equal( :x, g.rotate_turn )
    assert_equal( :x, g.turn )
    assert_equal( :o, g.next_turn )
    assert_equal( :o, g.rotate_turn )
    assert_equal( :o, g.turn )
  end

  def test_has_moves
    g = Game.new TicTacToe
    assert_equal( [:x], g.has_moves )
    g.rotate_turn
    assert_equal( [:o], g.has_moves )
    g.rotate_turn
    assert_equal( [:x], g.has_moves )
    g.rotate_turn
    assert_equal( [:o], g.has_moves )

    g = Game.new Footsteps
    assert_equal( [:left, :right], g.has_moves )
    g[:left] << g[:left].moves.first
    assert_equal( [:right], g.has_moves )
    g[:right] << g[:right].moves.first
    assert_equal( [:left, :right], g.has_moves )
    g[:right] << g[:right].moves.first
    assert_equal( [:left], g.has_moves )
  end

  def test_moves
    g = Game.new TicTacToe

    move = g.moves.first

    g << move

    assert_equal( [move], g.sequence )
  end

  def test_resign
    g = Game.new TicTacToe

    g[:x].user = Human.new "john_doe"
    g[:o].user = RandomBot.new "randombot"

    moves = g.moves

    assert( !g.final? )
    assert( !g.draw? )

    assert( g.special_move?( "x_resigns" ) )
    assert( g.special_move?( "o_resigns" ) )

    g[:x].user << "resign"
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

    assert_equal( "x_resigns", g.sequence.last )
    assert_equal( "randombot (o) defeated john_doe (x) (john_doe resigns)",
                  g.description )
  end

  def test_resign_off_turn
    g = Game.new TicTacToe

    g[:x].user = Human.new "john_doe"
    g[:o].user = Human.new "jane_doe"

    assert( g.special_move?( "x_resigns" ) )
    assert( g.special_move?( "o_resigns" ) )

    g[:o].user << "resign"

    assert( ! g[:x].user.ready? )
    assert(   g[:o].user.ready? )
    assert(   g.has_moves?( :x ) )
    assert( ! g.has_moves?( :o ) )
    
    g.step

    assert( g.final? )
    assert( g.resigned? )
    assert_equal( :o, g.resigned_by )
  end

  def test_draw_by_agreement_accept
    g = Game.new AmericanCheckers

    g[:red].user = Human.new "john_doe"
    g[:white].user = Human.new "jane_doe"

    moves = g.moves

    assert( !g.final? )
    assert( !g.draw? )

    assert( g.special_move?( "draw_offered_by_red" ) )
    assert( g.special_move?( "draw_offered_by_white" ) )

    g[:red].user << "offer_draw"
    g.step

    assert( g.draw_offered? )
    assert_equal( :red, g.draw_offered_by )
    assert_equal( :red, g.history.move_by.last )
    
    assert( g.moves.empty? )

    moves.each do |move|
      assert( ! g.move?( move ) )
    end

    assert( g.special_move?( "draw_accepted_by_white", :white ) )
    assert( g.special_move?( "reject_draw", :white ) )
    assert( ! g.special_move?( "draw_accepted_by_red", :red ) )
    assert( ! g.special_move?( "reject_draw", :red ) )

    assert_equal( ["draw_accepted_by_white", "reject_draw"], 
                  g.special_moves( :white).sort )

    g[:white].user << "accept_draw"
    g.step
    
    assert_equal( nil, g.history.move_by.last )

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

    g[:red].user = Human.new "john_doe"
    g[:white].user = Human.new "jane_doe"

    moves = g.moves

    assert( !g.final? )
    assert( !g.draw? )

    assert( g.special_move?( "draw_offered_by_red" ) )
    assert( g.special_move?( "draw_offered_by_white" ) )

    g[:red].user << "offer_draw"
    g.step

    assert( g.draw_offered? )
    assert_equal( :red, g.draw_offered_by )
    
    assert( g.moves.empty? )

    moves.each do |move|
      assert( ! g.move?( move ) )
    end

    assert( g.special_move?( "draw_accepted_by_white", :white ) )
    assert( g.special_move?( "reject_draw", :white ) )
    assert( ! g.special_move?( "draw_accepted_by_red", :red ) )
    assert( ! g.special_move?( "reject_draw", :red ) )

    assert_equal( ["draw_accepted_by_white", "reject_draw"], 
                  g.special_moves( :white).sort )

    g[:white] << "reject_draw"
    g.step
    
    assert( ! g.draw_offered? )
    assert( ! g.draw_by_agreement? )

    assert( ! g.final? )

    assert( ! g.special_move?( "draw_accepted_by_white" ) )
    assert( ! g.special_move?( "reject_draw" ) )

    moves.each do |move|
      assert( g.move?( move ) )
    end
  end

  def test_time_exceeded
    g = Game.new TicTacToe

    g[:x].user = Human.new "john_doe"
    g[:o].user = RandomBot.new "randombot"

    moves = g.moves

    assert( g.special_move?( "time_exceeded_by_x" ) )
    assert( g.special_move?( "time_exceeded_by_o" ) )

    g << "time_exceeded_by_x"

    assert_equal( :x, g.history.move_by.last )

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
    g[:x].user = Human.new "john_doe"
    g[:o].user = Human.new "jane_doe"

    assert_equal( 0, g.sequence.length )
    assert_equal( 1, g.history.length )

    move = g.moves.first
    g << move

    assert_equal( 1, g.sequence.length )
    assert_equal( 2, g.history.length )
    assert_equal( move, g.sequence.last )
    assert( :x, g.history.move_by.last )

    m, p = g.undo

    assert_equal( 0, g.sequence.length )
    assert_equal( 1, g.history.length )
    assert_equal( move, m.to_s )
    assert( g.history.move_by.empty? )

    move = "x_resigns"
    g << move

    assert_equal( 1, g.sequence.length )
    assert_equal( 2, g.history.length )
    assert_equal( move, g.sequence.last )
    assert( :x, g.history.move_by.last )
    
    m, p = g.undo

    assert_equal( 0, g.sequence.length )
    assert_equal( 1, g.history.length )
    assert_equal( move, m.to_s )
    assert( g.history.move_by.empty? )
  end

  def test_undo_by_request
    g = Game.new TicTacToe
    g[:x].user = Human.new "john_doe"
    g[:o].user = Human.new "jane_doe"

    assert_equal( 0, g.sequence.length )
    assert_equal( 1, g.history.length )

    move = g.moves.first
    g << move

    assert_equal( 1, g.sequence.length )
    assert_equal( 2, g.history.length )
    assert_equal( move, g.sequence.last )
    assert( :x, g.history.move_by.last )

    assert( g.special_move?( "undo_requested_by_x" ) )
    assert( g.special_move?( "undo_requested_by_o" ) )

    g[:x].user << "request_undo"
    g.step

    assert( g.undo_requested? )
    assert_equal( "undo_requested_by_x", g.sequence.last )
    assert_equal( :x, g.undo_requested_by )
    assert( g.undo_requested_by?( :x ) )
    assert_equal( [:o], g.has_moves )
    assert( :x, g.history.move_by.last )

    assert( g.special_move?( "undo_accepted_by_o", :o ) )
    assert( g.special_move?( "reject_undo", :o ) )
    assert( ! g.special_move?( "undo_accepted_by_x", :x ) )
    assert( ! g.special_move?( "reject_undo", :x ) )

    assert_equal( ["undo_accepted_by_o", "reject_undo"].sort,
                  g.special_moves( :o ).sort )

    g[:o] << "reject_undo"
    g.step

    assert_equal( 1, g.sequence.length )
    assert_equal( 2, g.history.length )
    assert_equal( move, g.sequence.last )
    assert( :x, g.history.move_by.last )

    g[:o].user << "request_undo"
    g.step

    assert( g.undo_requested? )
    assert_equal( "undo_requested_by_o", g.sequence.last )
    assert_equal( :o, g.undo_requested_by )
    assert( g.undo_requested_by?( :o ) )
    assert_equal( [:x], g.has_moves )
    assert( :o, g.history.move_by.last )

    assert( g.special_move?( "undo_accepted_by_x", :x ) )
    assert( g.special_move?( "reject_undo", :x ) )
    assert( ! g.special_move?( "undo_accepted_by_o", :o ) )
    assert( ! g.special_move?( "reject_undo", :o ) )

    assert_equal( ["undo_accepted_by_x", "reject_undo"].sort,
                  g.special_moves( :x ).sort )

    g[:x].user << "accept_undo"
    g.step

    assert( ! g.special_move?( "undo_accepted_by_x" ) )
    assert( ! g.special_move?( "reject_undo" ) )
    assert( g.history.move_by.empty? )

    assert_equal( 0, g.sequence.length )
    assert_equal( 1, g.history.length )
  end

  def test_undo_by_request_three_players
    return unless Vying::RandomSupport  # TODO: replace Hexxagon with a 
                                        #       non-random 3-player game

    g = Game.new Hexxagon, :number_of_players => 3
    g[:red].user = Human.new "john_doe"
    g[:white].user = Human.new "jane_doe"
    g[:blue].user = Human.new "dude"

    assert_equal( 0, g.sequence.length )
    assert_equal( 1, g.history.length )

    move = g.moves.first
    g << move

    assert_equal( 1, g.sequence.length )
    assert_equal( 2, g.history.length )
    assert_equal( move, g.sequence.last )
    assert( :red, g.history.move_by.last )

    assert( g.special_move?( "undo_requested_by_red" ) )
    assert( g.special_move?( "undo_requested_by_white" ) )
    assert( g.special_move?( "undo_requested_by_blue" ) )

    g[:red].user << "request_undo"
    g.step

    assert( g.undo_requested? )
    assert_equal( "undo_requested_by_red", g.sequence.last )
    assert_equal( :red, g.undo_requested_by )
    assert( g.undo_requested_by?( :red ) )
    assert( g.has_moves?( :white ) )
    assert( g.has_moves?( :blue ) )
    assert( ! g.has_moves?( :red ) )
    assert( :red, g.history.move_by.last )

    assert( g.special_move?( "undo_accepted_by_white", :white ) )
    assert( g.special_move?( "undo_accepted_by_blue", :blue ) )
    assert( g.special_move?( "reject_undo", :white ) )
    assert( g.special_move?( "reject_undo", :blue ) )
    assert( ! g.special_move?( "undo_accepted_by_red", :red ) )
    assert( ! g.special_move?( "reject_undo", :red ) )

    assert_equal( ["undo_accepted_by_white", 
                   "undo_accepted_by_blue",
                   "time_exceeded_by_white",
                   "time_exceeded_by_red",
                   "time_exceeded_by_blue",
                   "reject_undo"].sort,
                  g.special_moves.map { |m| m.to_s }.sort )

    g[:white].user << "accept_undo"
    g.step

    assert( g.undo_requested? )
    assert_equal( "undo_accepted_by_white", g.sequence.last )
    assert_equal( "undo_requested_by_red", g.sequence[g.sequence.length - 2] )
    assert_equal( :red, g.undo_requested_by )
    assert( g.undo_requested_by?( :red ) )
    assert( ! g.has_moves?( :white ) )
    assert( g.has_moves?( :blue ) )
    assert( ! g.has_moves?( :red ) )
    assert( :white, g.history.move_by.last )

    assert( ! g.special_move?( "undo_accepted_by_white", :white ) )
    assert( g.special_move?( "undo_accepted_by_blue", :blue ) )
    assert( ! g.special_move?( "reject_undo", :white ) )
    assert( g.special_move?( "reject_undo", :blue ) )
    assert( ! g.special_move?( "undo_accepted_by_red", :red ) )
    assert( ! g.special_move?( "reject_undo", :red ) )

    assert_equal( ["undo_accepted_by_blue",
                   "time_exceeded_by_white",
                   "time_exceeded_by_red",
                   "time_exceeded_by_blue",
                   "reject_undo"].sort,
                  g.special_moves.sort )

    g2 = Game.replay( g )

    g[:blue] << "reject_undo"
    g.step

    assert_equal( 1, g.sequence.length )
    assert_equal( 2, g.history.length )
    assert_equal( move, g.sequence.last )
    assert( :red, g.history.move_by.last )

    assert( g.history != g2.history )

    g = g2

    g[:blue].user << "accept_undo"
    g.step

    assert( ! g.special_move?( "undo_accepted_by_blue" ) )
    assert( ! g.special_move?( "undo_accepted_by_red" ) )
    assert( ! g.special_move?( "undo_accepted_by_white" ) )
    assert( ! g.special_move?( "reject_undo" ) )

    assert_equal( 0, g.sequence.length )
    assert_equal( 1, g.history.length )
    assert( g.history.move_by.empty? )
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

    u << "resign"

    assert( u.resign?( nil, nil, nil ) )
    assert( ! u.resign?( nil, nil, nil ) )
  end

  def test_who
    g = Game.new TicTacToe

    g[:x].user = Human.new "john_doe"
    g[:o].user = Human.new "jane_doe"

    assert_equal( :x, g.who?( :x ) )
    assert_equal( :o, g.who?( :o ) )

    assert_equal( nil, g.who?( nil ) )

    assert_equal( :x, g.who?( g[:x].user ) )
    assert_equal( :o, g.who?( g[:o].user ) )

    assert_equal( g.move?( g.moves( :x ).first, :x ),
                  g.move?( g.moves( g[:x].user ).first, g[:x].user ) )

    assert_equal( g.move?( g.moves( :o ).first, :o ),
                  g.move?( g.moves( g[:o].user ).first, g[:o].user ) )

    assert_equal( g.has_moves?( :x ), g.has_moves?( g[:x].user ) )
    assert_equal( g.has_moves?( :o ), g.has_moves?( g[:o].user ) )

    g = Game.new Othello

    g[:black].user = Human.new "john_doe"
    g[:white].user = Human.new "jane_doe"

    assert_equal( g.score( :black ), g.score( g[:black].user ) )
    assert_equal( g.score( :white ), g.score( g[:white].user ) )
  end

  def test_pie_rule
    g = Game.new Y
    g[:blue].user = Human.new "john_doe"
    g[:red].user  = Human.new "jane_doe"

    assert( ! g.special_move?( "swap" ) )
    assert( ! g.swapped? )

    g << g.moves.first

    assert( g.special_move?( "swap" ) )
    assert( g.special_move?( "swap", :red ) )
    assert( ! g.special_move?( "swap", :blue ) )

    g << "swap"

    assert( ! g.special_move?( "swap" ) )
    assert_equal( 1, g.swapped? )
    assert_equal( g.history[1], g.history.last )
    assert_equal( "swap", g.sequence.last )
    assert_equal( Human.new( "jane_doe" ), g[:blue].user )
    assert_equal( Human.new( "john_doe" ), g[:red].user )
    assert( :red, g.history.move_by.last )
  end

  def test_pie_rule_02
    g = Game.new Kalah, :seeds_per_cup => 3
    g[:one].user = Human.new "john_doe"
    g[:two].user  = Human.new "jane_doe"

    assert( ! g.special_move?( "swap" ) )
    assert( ! g.swapped? )

    g << "c1"

    assert( ! g.swapped? )
    assert( ! g.special_move?( "swap" ) )
    assert( ! g.special_move?( "swap", :one ) )
    assert( ! g.special_move?( "swap", :two ) )

    g << g.moves.first

    assert( ! g.swapped? )
    assert( g.special_move?( "swap" ) )
    assert( ! g.special_move?( "swap", :one ) )
    assert( g.special_move?( "swap", :two ) )

    g << "swap"

    assert( ! g.special_move?( "swap" ) )
    assert( ! g.special_move?( "swap", :one ) )
    assert( ! g.special_move?( "swap", :two ) )
    assert_equal( 2, g.swapped? )
    assert_equal( g.history[2], g.history.last )
    assert_equal( "swap", g.sequence.last )
    assert_equal( Human.new( "jane_doe" ), g[:one].user )
    assert_equal( Human.new( "john_doe" ), g[:two].user )
    assert( :red, g.history.move_by.last )
  end

  def test_pie_rule_03
    g = Game.new Kalah, :seeds_per_cup => 3
    g[:one].user = Human.new "john_doe"
    g[:two].user  = Human.new "jane_doe"

    assert( ! g.special_move?( "swap" ) )
    assert( ! g.swapped? )

    g << "c1"

    assert( ! g.swapped? )
    assert( ! g.special_move?( "swap" ) )
    assert( ! g.special_move?( "swap", :one ) )
    assert( ! g.special_move?( "swap", :two ) )

    g << g.moves.first

    assert( ! g.swapped? )
    assert( g.special_move?( "swap" ) )
    assert( ! g.special_move?( "swap", :one ) )
    assert( g.special_move?( "swap", :two ) )

    g << g.moves.first 

    assert( ! g.swapped? )
    assert( ! g.special_move?( "swap" ) )
    assert( ! g.special_move?( "swap", :one ) )
    assert( ! g.special_move?( "swap", :two ) )
  end

  def test_withdraw
    g = Game.new Othello

    assert( ! g.unrated? )

    assert( ! g.special_moves.include?( "black_withdraws" ) )
    assert( ! g.special_moves.include?( "white_withdraws" ) )
  
    g[:black].user = Human.new "john_doe"
    g[:white].user = Human.new "jane_doe"

    assert( ! g.special_moves.include?( "black_withdraws" ) )
    assert( ! g.special_moves.include?( "white_withdraws" ) )
  
    g.instance_variable_set( "@unrated", true )

    assert( g.unrated? )

    assert( g.special_moves.include?( "black_withdraws" ) )
    assert( g.special_moves.include?( "white_withdraws" ) )
  
    assert( g.special_moves( :black ).include?( "black_withdraws" ) )
    assert( ! g.special_moves( :black ).include?( "white_withdraws" ) )
  
    g << "black_withdraws"

    assert_equal( nil, g[:black].user )
    assert( ! g.special_moves.include?( "black_withdraws" ) )
    assert( ! g.special_moves( :black ).include?( "black_withdraws" ) )
    assert( g.special_moves.include?( "white_withdraws" ) )
    assert( :black, g.history.move_by.last )

    g[:black].user = Human.new "dude"
  
    assert( g.special_moves.include?( "black_withdraws" ) )
    assert( g.special_moves.include?( "white_withdraws" ) )

    g << "white_withdraws"
  
    assert_equal( nil, g[:white].user )
    assert( g.special_moves.include?( "black_withdraws" ) )
    assert( ! g.special_moves.include?( "white_withdraws" ) )
    assert( :white, g.history.move_by.last )

  end

  def test_kick
    g = Game.new Othello

    assert( ! g.unrated? )

    assert( ! g.special_moves.include?( "kick_black" ) )
    assert( ! g.special_moves.include?( "kick_white" ) )
  
    g[:black].user = Human.new "john_doe"
    g[:white].user = Human.new "jane_doe"

    assert( ! g.special_moves.include?( "kick_black" ) )
    assert( ! g.special_moves.include?( "kick_white" ) )
  
    g.instance_variable_set( "@unrated", true )

    assert( g.unrated? )

    assert( g.special_moves.include?( "kick_black" ) )
    assert( g.special_moves.include?( "kick_white" ) )
  
    assert( g.special_moves( :black ).include?( "kick_white" ) )
    assert( ! g.special_moves( :black ).include?( "kick_black" ) )
  
    g << "kick_white"

    assert_equal( nil, g[:white].user )
    assert( ! g.special_moves.include?( "kick_white" ) )
    assert( ! g.special_moves( :black ).include?( "kick_white" ) )
    assert( g.special_moves.include?( "kick_black" ) )
    assert( ! g.special_moves( :white ).include?( "kick_black" ) )
    assert( :white, g.history.move_by.last )

    g[:white].user = Human.new "dude"
  
    assert( g.special_moves.include?( "kick_black" ) )
    assert( g.special_moves.include?( "kick_white" ) )

    g << "kick_black"
  
    assert_equal( nil, g[:black].user )
    assert( g.special_moves.include?( "kick_white" ) )
    assert( ! g.special_moves.include?( "kick_black" ) )
    assert( :black, g.history.move_by.last )

    # Can't we all just get along?
  end

  def test_consecutive_special_moves
    g = Game.new( PahTum )

    g << g.moves.first

    g << "swap"

    g << "time_exceeded_by_black"

    assert( g.time_exceeded? )
    assert( g.time_exceeded_by?( :black ) )
    assert_equal( :black, g.time_exceeded_by )
  end

  def test_history_since
    t = Time.now
    g = Game.new TicTacToe

    assert_equal( [], g.history.since( t ) )

    g << g.moves.first

    assert_equal( [g.history.last], g.history.since( t ) )

    g << g.moves.first

    assert_equal( [g.history[1], g.history[2]], g.history.since( t ) )

    t = Time.now

    assert_equal( [], g.history.since( t ) )

    g << g.moves.first

    assert_equal( [g.history[3]], g.history.since( t ) )
  end

  def test_history_last_move_at_01
    t = Time.now
    g = Game.new TicTacToe

    assert( g.created_at > t )
    assert( g.history.created_at > t )

    assert_equal( g.created_at, g.last_move_at )

    g << g.moves.first

    assert( g.created_at < g.last_move_at )
    assert_equal( g.history.moves.last.at, g.last_move_at )

    t2 = g.history.moves.last.at
    g << g.moves.first

    assert( g.created_at < g.last_move_at )
    assert_equal( g.history.moves.last.at, g.last_move_at )
    assert( g.history.moves.first.at > g.created_at )
    assert( g.history.moves.last.at > g.history.moves.first.at )

    g << "undo_requested_by_x"

    assert( g.created_at < g.last_move_at )
    assert_equal( g.history.moves.last.at, g.last_move_at )
    assert( g.history.moves[2].at > g.history.moves[1].at )

    t3 = g.history.moves.last.at
    g << "undo_accepted_by_o"

    assert( g.created_at < g.last_move_at )
    assert( g.history.moves.last.at < g.last_move_at )
    assert( g.history.moves.last.at == t2 )
    assert( t3 < g.last_move_at )

    g << g.moves.first

    assert_equal( g.history.moves.last.at, g.last_move_at )
  end

  def test_last_move_at_02
    t = Time.now
    g = Game.new Connect6

    assert( g.created_at > t )
    assert( g.history.created_at > t )

    assert_equal( g.created_at, g.last_move_at )

    g << g.moves.first
    t2 = g.history.moves.last.at

    assert( g.created_at < g.last_move_at )
    assert_equal( g.history.moves.last.at, g.last_move_at )
    
    g << g.moves.first
    t3 = g.history.moves.last.at

    g << "undo"

    assert_equal( t2, g.history.moves.last.at )
    assert( g.last_move_at > t2 )
    assert( g.last_move_at > t3 )
  end

  def test_time_limit

    # This test is timing specific == BAD!
    # On a reasonably fast machine, this should pass without problems, but
    # on a slow machine it's possible it could fail...

    g = Game.new TicTacToe
    g.time_limit = 1  # seconds
   
    assert( g.timed? ) 
    assert( g.time_remaining > 0 )
    assert( g.expiration > Time.now )
    assert( ! g.time_up? )
    assert( ! g.timeout! )

    sleep 2

    assert( g.time_remaining < 0 )
    assert( g.expiration < Time.now )
    assert_equal( :x, g.time_up? )
    assert( g.timeout! )

    assert( g.final? )
    assert( g.winner?( :o ) )
    assert( g.loser?( :x ) )

    assert_equal( "time_exceeded_by_x", g.history.moves.last.to_s )

    g = Game.new TicTacToe

    assert( ! g.timed? )
    assert( ! g.time_remaining )
    assert( ! g.expiration )
    assert( ! g.time_up? )
    assert( ! g.timeout! )
  end

  def test_history_last_move
    g = Game.new Phutball

    assert_equal( [], g.history.last_turn.map { |m| m.to_s } )

    g << "h10"

    assert_equal( ["h10"], g.history.last_turn.map { |m| m.to_s } )

    g << "i12"

    assert_equal( ["i12"], g.history.last_turn.map { |m| m.to_s } )

    g << "h8"

    assert_equal( ["h8"], g.history.last_turn.map { |m| m.to_s } )

    g << "k14"

    assert_equal( ["k14"], g.history.last_turn.map { |m| m.to_s } )

    g << "h11h9"

    assert_equal( ["h11h9"], g.history.last_turn.map { |m| m.to_s } )

    g << "h9h7"

    assert_equal( ["h11h9", "h9h7"], g.history.last_turn.map { |m| m.to_s } )

    i = g.history.moves.length - 1

    assert_equal( ["h11h9", "h9h7"], 
      g.history.last_turn( i ).map { |m| m.to_s } )

    g << "undo_requested_by_ohs"

    assert_equal( [], g.history.last_turn.map { |m| m.to_s } )

    assert_equal( ["h11h9", "h9h7"], 
      g.history.last_turn( i ).map { |m| m.to_s } )
    
  end

end

