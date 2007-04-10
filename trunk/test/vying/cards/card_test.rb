require 'test/unit'

require 'vying/cards/card'

class TestCard < Test::Unit::TestCase

  def test_initialize
    c = Card.new( :clubs, 9 )
    assert_equal( :clubs, c.suit )
    assert_equal( 9, c.rank )
    assert_equal( :black, c.color )
    assert_equal( 9, c.pips )

    c = Card[:HA]
    assert_equal( :hearts, c.suit )
    assert_equal( :ace, c.rank )
    assert_equal( :red, c.color )
    assert_equal( 1, c.pips )
  end

  def test_sort
    cards =  [Card[:HA],Card[:C9],Card[:CK],Card[:H3],Card[:S9]]
    sorted = [Card[:CK],Card[:C9],Card[:S9],Card[:HA],Card[:H3]]

    assert_equal( sorted, cards.sort )
  end

end

