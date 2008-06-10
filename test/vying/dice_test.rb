require 'test/unit'

require 'vying'

class TestDie < Test::Unit::TestCase
  def test_initialize
    die = Die.new( 3 )

    assert_equal( 3, die.up )
    assert_equal( :white, die.color )
    assert_equal( [1,2,3,4,5,6], die.faces )

    die = Die.new( 4, :black, [1,1,1,4,4,4] )

    assert_equal( 4, die.up )
    assert_equal( :black, die.color )
    assert_equal( [1,1,1,4,4,4], die.faces )
  end

  def test_roll
    return unless Vying::RandomSupport

    rng = RandomNumberGenerator.new 1234
    die = Die.new 3

    assert_equal( 4, die.roll( rng ) )
    assert_equal( 4, die.up )

    assert_equal( 6, die.roll( rng ) )
    assert_equal( 6, die.up )

    assert_equal( 5, die.roll( rng ) )
    assert_equal( 5, die.up )
  end

  def test_to_s
    die = Die.new 3
    assert_equal( "3", die.to_s )

    die = Die.new 1
    assert_equal( "1", die.to_s )
  end

end

class TestDice < Test::Unit::TestCase
  def test_initialize
    dice = Dice.new( [Die.new( 1 ), Die.new( 1 ), Die.new( 3 )] )

    assert_equal( 3, dice.length )
    assert_equal( Die.new( 1 ), dice[0] )
    assert_equal( Die.new( 1 ), dice[1] )
    assert_equal( Die.new( 3 ), dice[2] )
  end

  def test_include
    dice = Dice.new( [Die.new( 1 ), Die.new( 1 ), Die.new( 3 )] )

    assert( dice.include?( [1] ) )
    assert( dice.include?( [1,1] ) )
    assert( dice.include?( [3,1] ) )
    assert( dice.include?( [3] ) )
    assert( dice.include?( [1,3,1] ) )
  end

end

