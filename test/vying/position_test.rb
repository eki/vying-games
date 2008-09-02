
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

  def test_dup_with_special_move_mixin
    p = Connect6.new

    p2 = SpecialMove["draw"].apply_to_position( p )

    assert_not_equal( p, p2 )
    assert_equal( p2, p2.dup )
    assert_equal( p2.draw?, p2.dup.draw? )

    p3 = p2.remove_special_mixin

    assert_not_equal( p2, p3 )
    assert_equal( p, p3 )
    assert_not_equal( p2.draw?, p3.draw? )
  end

  def test_marshal_with_special_move_mixin
    p = Connect6.new

    p2 = SpecialMove["draw"].apply_to_position( p )

    assert_not_equal( p, p2 )
    assert_equal( p2, Marshal.load( Marshal.dump( p2 ) ) )
    assert_equal( p2.draw?, Marshal.load( Marshal.dump( p2 ) ).draw? )
  end

  def test_yaml_with_special_move_mixin
    p = Connect6.new

    p2 = SpecialMove["draw"].apply_to_position( p )

    assert_not_equal( p, p2 )
    assert_equal( p2, YAML.load( p2.to_yaml ) )
    assert_equal( p2.draw?, YAML.load( p2.to_yaml ).draw? )
  end
end

