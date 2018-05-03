require_relative '../../../test_helper'

class TestDodgem < Minitest::Test
  include RulesTests

  def rules
    Dodgem
  end

  def test_info
    assert_equal( "Dodgem", rules.name )
  end

  def test_players
    assert_equal( [:blue,:red], rules.new.players )
  end

  def test_initialize
    g = Game.new( rules )
    assert_equal( :blue, g.turn )
    assert_equal( 4, g.options[:board_size] )

    assert_equal( 3, g.board.count( :blue ) )
    assert_equal( 3, g.board.count( :red ) )

    assert_equal( [:blue, :blue, :blue], g.board[:a2, :a3, :a4] )
    assert_equal( [:red,  :red,  :red ], g.board[:b5, :c5, :d5] )

    g = Game.new( rules, :board_size => 3 )
    assert_equal( :blue, g.turn )
    assert_equal( 3, g.options[:board_size] )

    assert_equal( 2, g.board.count( :blue ) )
    assert_equal( 2, g.board.count( :red ) )

    assert_equal( [:blue, :blue], g.board[:a2, :a3] )
    assert_equal( [:red,  :red ], g.board[:b4, :c4] )

    g = Game.new( rules, :board_size => 5 )
    assert_equal( :blue, g.turn )
    assert_equal( 5, g.options[:board_size] )

    assert_equal( 4, g.board.count( :blue ) )
    assert_equal( 4, g.board.count( :red ) )

    assert_equal( [:blue, :blue, :blue, :blue], g.board[:a2, :a3, :a4, :a5] )
    assert_equal( [:red,  :red,  :red,  :red ], g.board[:b6, :c6, :d6, :e6] )
  end

  def test_has_moves
    g = Game.new( rules )
    assert_equal( [:blue], g.has_moves )
    g << g.moves.first
    assert_equal( [:red], g.has_moves )
    g << g.moves.first
    assert_equal( [:blue], g.has_moves )
  end

  def test_initial_moves
    g = Game.new rules, :board_size => 3

    assert_equal( ["a2b2", "a3a4", "a3b3"], g.moves.sort )

    g << "a2b2"

    assert_equal( ["b4a4", "b4b3", "c4c3"], g.moves.sort )

    g << "b4a4"

    assert_equal( ["a3a2", "a3b3", "b2b3", "b2c2"], g.moves.sort )

    g << "b2c2"

    assert_equal( ["a4b4", "c4b4", "c4c3"], g.moves.sort )

    g << "c4c3"

    assert_equal( ["a3a2", "a3b3", "c2d2"], g.moves.sort )

    g << "c2d2"

    assert_equal( ["a4b4", "c3b3", "c3c2"], g.moves.sort )

    assert_equal( 1, g.board.count( :blue ) )
    assert_equal( 2, g.board.count( :red ) )
    assert_equal( :blue, g.board[:a3] )
    assert_equal( [:red, :red], g.board[:a4, :c3] )
  end

end

