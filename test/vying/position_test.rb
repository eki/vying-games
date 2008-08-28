
require 'test/unit'
require 'vying'

class TestPosition < Test::Unit::TestCase

  def test_censor
    return unless Vying::RandomSupport

    p = Ataxx.new 1234
    assert_equal( :hidden, p.censor( :red ).rng )
    assert_equal( :hidden, p.censor( :blue ).rng )
    assert_not_equal( :hidden, p.censor( :red ).board )
    assert_not_equal( :hidden, p.censor( :blue ).board )
  end

  def test_turn
    p = TicTacToe.new
    assert_equal( :x, p.turn )
    assert_equal( :o, p.next_turn )
    assert_equal( :o, p.rotate_turn )
    assert_equal( :o, p.turn )
    assert_equal( :x, p.rotate_turn )
    assert_equal( :x, p.turn )
    assert_equal( :o, p.next_turn )
    assert_equal( :o, p.rotate_turn )
    assert_equal( :o, p.turn )
  end

  def test_has_moves
    p = TicTacToe.new
    assert_equal( [:x], p.has_moves )

    p.rotate_turn
    assert_equal( [:o], p.has_moves )

    p.rotate_turn
    assert_equal( [:x], p.has_moves )

    p.rotate_turn
    assert_equal( [:o], p.has_moves )

    p = Footsteps.new
    assert_equal( [:left, :right], p.has_moves )

    p.apply!( p.moves( :left ).first, :left )
    assert_equal( [:right], p.has_moves )

    p.apply!( p.moves( :right ).first, :right )
    assert_equal( [:left, :right], p.has_moves )

    p.apply!( p.moves( :right ).first, :right )
    assert_equal( [:left], p.has_moves )
  end

  def test_opponent
    p = TicTacToe.new
    
    assert_equal( :o, p.opponent( :x ) )
    assert_equal( :x, p.opponent( :o ) )

    p = Hexxagon.new :number_of_players => 3

    assert_equal( [:blue, :white], p.opponent( :red ) )
    assert_equal( [:red, :white], p.opponent( :blue ) )
    assert_equal( [:red, :blue], p.opponent( :white ) )
  end

end

