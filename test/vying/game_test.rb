
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
    assert( ! g.rng )

    return unless Vying::RandomSupport

    g = Game.new Ataxx, 1234
    assert_equal( Ataxx, g.rules )
    assert_equal( [], g.sequence )
    assert_equal( History.new( Ataxx.new( 1234 ) ), g.history )
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

  def test_resign
    g = Game.new TicTacToe

    g[:x] = Human.new "john_doe"
    g[:o] = RandomBot.new "randombot"

    moves = g.moves

    assert( !g.final? )
    assert( !g.draw? )

    assert( g.special_move?( "x_resigns" ) )
    assert( g.special_move?( "o_resigns" ) )

    g[:x] << "resign"
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

    g[:x] = Human.new "john_doe"
    g[:o] = Human.new "jane_doe"

    assert( g.special_move?( "x_resigns" ) )
    assert( g.special_move?( "o_resigns" ) )

    g[:o] << "resign"

    assert( ! g[:x].ready? )
    assert(   g[:o].ready? )
    assert(   g.has_moves?( :x ) )
    assert( ! g.has_moves?( :o ) )
    
    g.step

    assert( g.final? )
    assert( g.resigned? )
    assert_equal( :o, g.resigned_by )
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

    g[:white] << "accept_draw"
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

    g[:x] = Human.new "john_doe"
    g[:o] = RandomBot.new "randombot"

    moves = g.moves

    assert( g.special_move?( "time_exceeded_by_x" ) )
    assert( g.special_move?( "time_exceeded_by_o" ) )

    g << "time_exceeded_by_x"

    assert_equal( nil, g.history.move_by.last )

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
    assert( :x, g.history.move_by.last )

    m, mb, p = g.undo

    assert_equal( 0, g.sequence.length )
    assert_equal( 1, g.history.length )
    assert_equal( move, m )
    assert( g.history.move_by.empty? )

    move = "x_resigns"
    g << move

    assert_equal( 1, g.sequence.length )
    assert_equal( 2, g.history.length )
    assert_equal( move, g.sequence.last )
    assert( :x, g.history.move_by.last )
    
    m, mb, p = g.undo

    assert_equal( 0, g.sequence.length )
    assert_equal( 1, g.history.length )
    assert_equal( move, m )
    assert( g.history.move_by.empty? )
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
    assert( :x, g.history.move_by.last )

    assert( g.special_move?( "undo_requested_by_x" ) )
    assert( g.special_move?( "undo_requested_by_o" ) )

    g[:x] << "request_undo"
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

    g[:o] << "request_undo"
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

    g[:x] << "accept_undo"
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
    g[:red] = Human.new "john_doe"
    g[:white] = Human.new "jane_doe"
    g[:blue] = Human.new "dude"

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

    g[:red] << "request_undo"
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
                  g.special_moves.sort )

    g[:white] << "accept_undo"
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

    g = g2

    g[:blue] << "accept_undo"
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
    assert_equal( Human.new( "jane_doe" ), g[:blue] )
    assert_equal( Human.new( "john_doe" ), g[:red] )
    assert( :red, g.history.move_by.last )
  end

  def test_pie_rule_02
    g = Game.new Kalah, :seeds_per_cup => 3
    g[:one] = Human.new "john_doe"
    g[:two]  = Human.new "jane_doe"

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
    assert_equal( Human.new( "jane_doe" ), g[:one] )
    assert_equal( Human.new( "john_doe" ), g[:two] )
    assert( :red, g.history.move_by.last )
  end

  def test_pie_rule_03
    g = Game.new Kalah, :seeds_per_cup => 3
    g[:one] = Human.new "john_doe"
    g[:two]  = Human.new "jane_doe"

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
  
    g[:black] = Human.new "john_doe"
    g[:white] = Human.new "jane_doe"

    assert( ! g.special_moves.include?( "black_withdraws" ) )
    assert( ! g.special_moves.include?( "white_withdraws" ) )
  
    g.instance_variable_set( "@unrated", true )

    assert( g.unrated? )

    assert( g.special_moves.include?( "black_withdraws" ) )
    assert( g.special_moves.include?( "white_withdraws" ) )
  
    assert( g.special_moves( :black ).include?( "black_withdraws" ) )
    assert( ! g.special_moves( :black ).include?( "white_withdraws" ) )
  
    g << "black_withdraws"

    assert_equal( nil, g[:black] )
    assert( ! g.special_moves.include?( "black_withdraws" ) )
    assert( ! g.special_moves( :black ).include?( "black_withdraws" ) )
    assert( g.special_moves.include?( "white_withdraws" ) )
    assert( :black, g.history.move_by.last )

    g[:black] = Human.new "dude"
  
    assert( g.special_moves.include?( "black_withdraws" ) )
    assert( g.special_moves.include?( "white_withdraws" ) )

    g << "white_withdraws"
  
    assert_equal( nil, g[:white] )
    assert( g.special_moves.include?( "black_withdraws" ) )
    assert( ! g.special_moves.include?( "white_withdraws" ) )
    assert( :white, g.history.move_by.last )

  end

  def test_kick
    g = Game.new Othello

    assert( ! g.unrated? )

    assert( ! g.special_moves.include?( "kick_black" ) )
    assert( ! g.special_moves.include?( "kick_white" ) )
  
    g[:black] = Human.new "john_doe"
    g[:white] = Human.new "jane_doe"

    assert( ! g.special_moves.include?( "kick_black" ) )
    assert( ! g.special_moves.include?( "kick_white" ) )
  
    g.instance_variable_set( "@unrated", true )

    assert( g.unrated? )

    assert( g.special_moves.include?( "kick_black" ) )
    assert( g.special_moves.include?( "kick_white" ) )
  
    assert( g.special_moves( :black ).include?( "kick_white" ) )
    assert( ! g.special_moves( :black ).include?( "kick_black" ) )
  
    g << "kick_white"

    assert_equal( nil, g[:white] )
    assert( ! g.special_moves.include?( "kick_white" ) )
    assert( ! g.special_moves( :black ).include?( "kick_white" ) )
    assert( g.special_moves.include?( "kick_black" ) )
    assert( ! g.special_moves( :white ).include?( "kick_black" ) )
    assert( :white, g.history.move_by.last )

    g[:white] = Human.new "dude"
  
    assert( g.special_moves.include?( "kick_black" ) )
    assert( g.special_moves.include?( "kick_white" ) )

    g << "kick_black"
  
    assert_equal( nil, g[:black] )
    assert( g.special_moves.include?( "kick_white" ) )
    assert( ! g.special_moves.include?( "kick_black" ) )
    assert( :black, g.history.move_by.last )

    # Can't we all just get along?
  end

  def test_last_special_moves
    g = Game.new( PahTum )

    g << g.moves.first

    assert_equal( [], g.history.last_special_moves )

    g << "swap"

    assert_equal( ["swap"], g.history.last_special_moves )

    g << "time_exceeded_by_black"

    assert_equal( ["swap", "time_exceeded_by_black"], 
                  g.history.last_special_moves )

    assert( g.time_exceeded? )
    assert( g.time_exceeded_by?( :black ) )
    assert_equal( :black, g.time_exceeded_by )
  end

end

