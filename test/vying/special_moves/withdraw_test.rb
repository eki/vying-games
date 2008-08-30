
require 'test/unit'
require 'vying'

class TestWithdraw < Test::Unit::TestCase
  def sm
    Move::Withdraw
  end

  def test_wrap
    assert( sm["black_withdraws"] )
    assert( sm["x_withdraws"] )

    assert( ! sm["undo_accepted_by_black"] )
    assert( ! sm["withdraws"] )
    assert( ! sm["_withdraws"] )

    assert( SpecialMove["black_withdraws"] )
    assert( SpecialMove["x_withdraws"] )

    assert( ! SpecialMove["withdraws"] )
    assert( ! SpecialMove["_withdraws"] )

    assert( sm["black_withdraws"].kind_of?( sm ) )
    assert( sm["x_withdraws"].kind_of?( sm ) )

    assert( ! sm["undo_accepted_by_black"].kind_of?( sm ) )
    assert( ! sm["withdraws"].kind_of?( sm ) )

    assert( SpecialMove["black_withdraws"].kind_of?( sm ) )
    assert( SpecialMove["x_withdraws"].kind_of?( sm ) )

    assert( ! SpecialMove["undo_accepted_by_black"].kind_of?( sm ) )
    assert( ! SpecialMove["withdraws"].kind_of?( sm ) )
  end

  def test_by
    assert_equal( :black, sm["black_withdraws"].by )
    assert_equal( :x, sm["x_withdraws"].by )
  end

  def test_valid_for
    ttt = Game.new( TicTacToe )

    assert( ! sm["x_withdraws"].valid_for?( ttt ) )
    assert( ! sm["o_withdraws"].valid_for?( ttt ) )

    assert( ! sm["x_withdraws"].valid_for?( ttt, :x ) )
    assert( ! sm["o_withdraws"].valid_for?( ttt, :x ) )

    assert( ! sm["x_withdraws"].valid_for?( ttt, :o ) )
    assert( ! sm["o_withdraws"].valid_for?( ttt, :o ) )

    ttt.instance_variable_set( "@unrated", true )

    assert( ! sm["x_withdraws"].valid_for?( ttt ) )
    assert( ! sm["o_withdraws"].valid_for?( ttt ) )

    assert( ! sm["x_withdraws"].valid_for?( ttt, :x ) )
    assert( ! sm["o_withdraws"].valid_for?( ttt, :x ) )

    assert( ! sm["x_withdraws"].valid_for?( ttt, :o ) )
    assert( ! sm["o_withdraws"].valid_for?( ttt, :o ) )

    ttt[:x].user = Human.new( "dude" )

    assert( sm["x_withdraws"].valid_for?( ttt ) )
    assert( ! sm["o_withdraws"].valid_for?( ttt ) )

    assert( sm["x_withdraws"].valid_for?( ttt, :x ) )
    assert( ! sm["o_withdraws"].valid_for?( ttt, :x ) )

    assert( ! sm["x_withdraws"].valid_for?( ttt, :o ) )
    assert( ! sm["o_withdraws"].valid_for?( ttt, :o ) )

    ttt[:o].user = Human.new( "dudette" )

    assert( sm["x_withdraws"].valid_for?( ttt ) )
    assert( sm["o_withdraws"].valid_for?( ttt ) )

    assert( sm["x_withdraws"].valid_for?( ttt, :x ) )
    assert( ! sm["o_withdraws"].valid_for?( ttt, :x ) )

    assert( ! sm["x_withdraws"].valid_for?( ttt, :o ) )
    assert( sm["o_withdraws"].valid_for?( ttt, :o ) )

    ttt.instance_variable_set( "@unrated", false )

    assert( ! sm["x_withdraws"].valid_for?( ttt ) )
    assert( ! sm["o_withdraws"].valid_for?( ttt ) )

    assert( ! sm["x_withdraws"].valid_for?( ttt, :x ) )
    assert( ! sm["o_withdraws"].valid_for?( ttt, :x ) )

    assert( ! sm["x_withdraws"].valid_for?( ttt, :o ) )
    assert( ! sm["o_withdraws"].valid_for?( ttt, :o ) )
  end

  def test_effects_history
    assert( ! sm["red_withdraws"].effects_history? )
  end

  def test_generate_for
    ttt = Game.new( TicTacToe )

    assert( ! sm.generate_for( ttt ).include?( "x_withdraws" ) )
    assert( ! sm.generate_for( ttt ).include?( "o_withdraws" ) )

    assert( ! sm.generate_for( ttt, :x ).include?( "x_withdraws" ) )
    assert( ! sm.generate_for( ttt, :x ).include?( "o_withdraws" ) )

    assert( ! sm.generate_for( ttt, :o ).include?( "x_withdraws" ) )
    assert( ! sm.generate_for( ttt, :o ).include?( "o_withdraws" ) )

    ttt.instance_variable_set( "@unrated", true )

    assert( ! sm.generate_for( ttt ).include?( "x_withdraws" ) )
    assert( ! sm.generate_for( ttt ).include?( "o_withdraws" ) )

    assert( ! sm.generate_for( ttt, :x ).include?( "x_withdraws" ) )
    assert( ! sm.generate_for( ttt, :x ).include?( "o_withdraws" ) )

    assert( ! sm.generate_for( ttt, :o ).include?( "x_withdraws" ) )
    assert( ! sm.generate_for( ttt, :o ).include?( "o_withdraws" ) )

    ttt[:x].user = Human.new( "dude" )

    assert( sm.generate_for( ttt ).include?( "x_withdraws" ) )
    assert( ! sm.generate_for( ttt ).include?( "o_withdraws" ) )

    assert( sm.generate_for( ttt, :x ).include?( "x_withdraws" ) )
    assert( ! sm.generate_for( ttt, :x ).include?( "o_withdraws" ) )

    assert( ! sm.generate_for( ttt, :o ).include?( "x_withdraws" ) )
    assert( ! sm.generate_for( ttt, :o ).include?( "o_withdraws" ) )

    ttt[:o].user = Human.new( "dudette" )

    assert( sm.generate_for( ttt ).include?( "x_withdraws" ) )
    assert( sm.generate_for( ttt ).include?( "o_withdraws" ) )

    assert( sm.generate_for( ttt, :x ).include?( "x_withdraws" ) )
    assert( ! sm.generate_for( ttt, :x ).include?( "o_withdraws" ) )

    assert( ! sm.generate_for( ttt, :o ).include?( "x_withdraws" ) )
    assert( sm.generate_for( ttt, :o ).include?( "o_withdraws" ) )

    ttt.instance_variable_set( "@unrated", false )

    assert( ! sm.generate_for( ttt ).include?( "x_withdraws" ) )
    assert( ! sm.generate_for( ttt ).include?( "o_withdraws" ) )

    assert( ! sm.generate_for( ttt, :x ).include?( "x_withdraws" ) )
    assert( ! sm.generate_for( ttt, :x ).include?( "o_withdraws" ) )

    assert( ! sm.generate_for( ttt, :o ).include?( "x_withdraws" ) )
    assert( ! sm.generate_for( ttt, :o ).include?( "o_withdraws" ) )
  end

end

