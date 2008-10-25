require 'test/unit'

require 'vying'
require 'vying/rules/rules_test'

class TestPhalango < Test::Unit::TestCase
  include RulesTests

  def rules
    Phalango
  end

  def test_info
    assert_equal( "Phalango", rules.name )
    assert( rules.version == '0.9.0' )
  end

  def test_players
    assert_equal( [:white, :black], rules.new.players )
  end

  def test_initialize
    g = Game.new( rules )

    assert_equal( 0, g.board.unoccupied.length )
    assert_equal( :white, g.turn )
  end

  def test_options
    assert_equal( 6, rules.options[:board_size].default )
    assert_equal( [4, 6, 8], rules.options[:board_size].values )

    assert_equal( 6, rules.new.board.length )
    assert_equal( 4, rules.new( :board_size => 4 ).board.length )
    assert_equal( 6, rules.new( :board_size => 6 ).board.length )
    assert_equal( 8, rules.new( :board_size => 8 ).board.length )

    assert_raise( RuntimeError ) { rules.new( :board_size => 2 ) }
    assert_raise( RuntimeError ) { rules.new( :board_size => 7 ) }
  end

  def test_has_moves
    g = Game.new( rules )
    assert_equal( [:white], g.has_moves )
    g << g.moves.first
    assert_equal( [:black], g.has_moves )
  end

  def test_play
    g = Game.new( rules )

    g << "a3a4" << "b4a4"
    assert( ! g.move?( "b3a4" ) )
  end

end

