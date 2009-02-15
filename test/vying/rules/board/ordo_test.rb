require 'test/unit'

require 'vying'
require 'vying/rules/rules_test'

class TestOrdo < Test::Unit::TestCase
  include RulesTests

  def rules
    Ordo
  end

  def test_info
    assert_equal( "Ordo", rules.name )
    assert( rules.version == '0.5.0' )
  end

  def test_players
    assert_equal( [:white, :black], rules.new.players )
  end

  def test_initialize
    g = Game.new( rules )

    assert_equal( 10, rules.new.board.width )
    assert_equal(  8, rules.new.board.height )

    assert_equal( 40, g.board.occupied.length )
    assert_equal( :white, g.turn )
  end

  def test_has_moves
    g = Game.new( rules )
    assert_equal( [:white], g.has_moves )
    g << g.moves.first
    assert_equal( [:black], g.has_moves )
  end

  def test_play
    g = Game.new( rules )
  end

end

