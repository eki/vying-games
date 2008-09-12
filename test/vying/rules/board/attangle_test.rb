require 'test/unit'

require 'vying'
require 'vying/rules/rules_test'

class TestAttangle < Test::Unit::TestCase
  include RulesTests

  def rules
    Attangle
  end

  def test_info
    assert_equal( "Attangle", rules.name )
  end

  def test_players
    assert_equal( [:white, :black], rules.new.players )
  end

  def test_initialize
    g = Game.new( rules )
    assert_equal( :white, g.turn )
  end

  def test_options
    assert_equal( 4, rules.options[:board_size].default )
    assert_equal( [3, 4, 5], rules.options[:board_size].values )

    assert_equal( 4, rules.new.board.length )
    assert_equal( 3, rules.new( :board_size => 3 ).board.length )
    assert_equal( 4, rules.new( :board_size => 4 ).board.length )
    assert_equal( 5, rules.new( :board_size => 5 ).board.length )

    assert_raise( RuntimeError ) { rules.new( :board_size => 2 ) }
    assert_raise( RuntimeError ) { rules.new( :board_size => 7 ) }
  end

  def test_has_moves
    g = Game.new( rules )
    assert_equal( [:white], g.has_moves )
    g << g.moves( :black ).first
    assert_equal( [:black], g.has_moves )
  end

  def test_placement
    g = Game.new( rules )

    g << "a1"
    assert_equal( [:white], g.board[:a1] )
    assert_equal( 17, g.stocks[:white] )
    assert_equal( 18, g.stocks[:black] )

    g << "c3"
    assert_equal( [:black], g.board[:c3] )
    assert_equal( 17, g.stocks[:white] )
    assert_equal( 17, g.stocks[:black] )

    g << "e3" << "g7"

    g << "a1e3c3"
    assert_equal( nil, g.board[:a1] )
    assert_equal( nil, g.board[:e3] )
    assert_equal( [:white, :black], g.board[:c3] )
    assert_equal( 17, g.stocks[:white] )
    assert_equal( 16, g.stocks[:black] )
  end

end

