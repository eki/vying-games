
require 'test/unit'
require 'vying'

class TestPosition < Test::Unit::TestCase
  include Vying

  def test_censor
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

  def test_move_with_move
    p = Footsteps.new  # Footsteps doesn't implement move?

    assert_equal( p.move?( 2, :left ), p.move?( Move.new( 2, :left ) ) )

    p2 = p.apply( 2, :left )

    assert_equal( p2.move?( 4, :right ), p2.move?( Move.new( 4, :right ) ) )
    assert( ! p2.move?( 4, :left ) )
    assert( ! p2.move?( Move.new( 4, :left ) ) )
  end

  def test_move_with_move_02
    p = Othello.new    # Othello implements move?

    assert_equal( p.move?( :d3, :black ), p.move?( Move.new( :d3, :black ) ) )

    p2 = p.apply( :d3, :black )

    assert_equal( p2.move?( :c3, :white ), p2.move?( Move.new( :c3, :white ) ) )
    assert( ! p2.move?( :c3, :black) )
    assert( ! p2.move?( Move.new( :c3, :black ) ) )
  end

  def test_apply_with_move
    p = Footsteps.new

    assert_equal( p.apply( 2, :left ), p.apply( Move.new( 2, :left ) ) )
    assert_equal( p.apply( 4, :right ), p.apply( Move.new( 4, :right ) ) )
  end

  def test_ambiguous_move
    p = Footsteps.new

    assert_raise( RuntimeError ) { p.apply( 2 ) }
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
    omit('Failing: Skip yaml, probably going to remove this support')
    p = Connect6.new

    p2 = SpecialMove["draw"].apply_to_position( p )

    assert_not_equal( p, p2 )

    p3 = YAML.load( p2.to_yaml )

    assert_equal( p2, p3 )
    assert_equal( p2.draw?, p3.draw? )
    assert_equal( p2.rules, p3.rules )
  end
end

