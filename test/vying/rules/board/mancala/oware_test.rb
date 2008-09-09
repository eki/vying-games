require 'test/unit'

require 'vying'
require 'vying/rules/rules_test'

class TestOware < Test::Unit::TestCase
  include RulesTests

  def rules
    Oware
  end

  def test_info
    assert_equal( "Oware", rules.name )
  end

  def test_players
    assert_equal( [:one,:two], rules.new.players )
  end

  def test_initialize
    g = Game.new( rules )

    b = Board.new( :shape => :rect, :width => 6, :height => 2, :fill => 4 )

    assert_equal( b, g.board )
    assert_equal( :one, g.turn )
    assert_equal( 0, g.score( :one ) )
    assert_equal( 0, g.score( :two ) )
  end

  def test_moves
    g = Game.new( rules )

    assert_equal( :one, g.turn )
    assert_equal( ['a1', 'b1', 'c1', 'd1', 'e1', 'f1'], g.moves )

    g << :a1

    assert_equal( :two, g.turn )
    assert_equal( ['a2', 'b2', 'c2', 'd2', 'e2', 'f2'], g.moves )

    g << :f2

    assert_equal( :one, g.turn )
    assert_equal( ['b1', 'c1', 'd1', 'e1', 'f1'], g.moves )

    g << :e1

    assert_equal( :two, g.turn )
    assert_equal( ['a2', 'b2', 'c2', 'd2', 'e2'], g.moves )

    g << g.moves.first until g.final?

    assert_not_equal( g.history.first, g.history.last )
  end

  def test_has_score
    g = Game.new( rules )

    assert( g.has_score? )
  end

  def test_capture_01
    g = Game.new( rules )
    g.board[:a1,:b2,:c2,:d2,:e2,:f2] = 2
    
    assert_equal( 0, g.score( :one ) )
    assert_equal( 0, g.score( :two ) )

    g << :b1

    assert_equal( 3, g.board[:a1] )
    assert_equal( 5, g.board[:a2] )
    assert_equal( 0, g.board[:b2] )
    assert_equal( 0, g.board[:c2] )
    assert_equal( 2, g.board[:d2] )

    assert_equal( 6, g.score( :one ) )
    assert_equal( 0, g.score( :two ) )
  end

  def test_capture_02
    g = Game.new( rules )
    g.board[:a1,:a2,:b2,:c2,:d2,:e2,:f2] = 2
    
    assert_equal( 0, g.score( :one ) )
    assert_equal( 0, g.score( :two ) )

    g << :b1

    assert_equal( 3, g.board[:a1] )
    assert_equal( 0, g.board[:a2] )
    assert_equal( 0, g.board[:b2] )
    assert_equal( 0, g.board[:c2] )
    assert_equal( 2, g.board[:d2] )

    assert_equal( 9, g.score( :one ) )
    assert_equal( 0, g.score( :two ) )
  end

  def test_no_capture
    g = Game.new( rules )
    g.board[:a1,:b1,:c1,:d1,:e1,:f1] = 2
    
    assert_equal( 0, g.score( :one ) )
    assert_equal( 0, g.score( :two ) )

    g << :f1

    assert_equal( 0, g.board[:f1] )
    assert_equal( 3, g.board[:e1] )
    assert_equal( 3, g.board[:d1] )
    assert_equal( 2, g.board[:c1] )

    assert_equal( 0, g.score( :one ) )
    assert_equal( 0, g.score( :two ) )
  end

  def test_no_grand_slam_01    # Capture all 6 cups
    g = Game.new( rules )
    g.board[:a2,:b2,:c2,:d2,:e2,:f2] = 2
    g.board[:a1] = 6

    assert_equal( 0, g.score( :one ) )
    assert_equal( 0, g.score( :two ) )

    g << :a1

    assert_equal( 3, g.board[:a2] )
    assert_equal( 3, g.board[:b2] )
    assert_equal( 3, g.board[:c2] )
    assert_equal( 3, g.board[:d2] )
    assert_equal( 3, g.board[:e2] )
    assert_equal( 3, g.board[:f2] )
    assert_equal( 4, g.board[:f1] )

    assert_equal( 0, g.score( :one ) )
    assert_equal( 0, g.score( :two ) )
  end

  def test_no_grand_slam_02    # Capture 5 cups, 1 cup already empty
    g = Game.new( rules )
    g.board[:a2,:b2,:c2,:d2,:e2] = 2
    g.board[:f2] = 0
    g.board[:a1] = 5

    assert_equal( 0, g.score( :one ) )
    assert_equal( 0, g.score( :two ) )

    g << :a1

    assert_equal( 3, g.board[:a2] )
    assert_equal( 3, g.board[:b2] )
    assert_equal( 3, g.board[:c2] )
    assert_equal( 3, g.board[:d2] )
    assert_equal( 3, g.board[:e2] )
    assert_equal( 0, g.board[:f2] )
    assert_equal( 4, g.board[:f1] )

    assert_equal( 0, g.score( :one ) )
    assert_equal( 0, g.score( :two ) )
  end

  def test_check_cycles
    assert( rules.check_cycles? )
  end

  def test_cycle
    g = Game.new( rules )
    g.board[:a1,:b1,:c1,:d1,:e1,:b2,:c2,:d2,:e2,:f2] = 0
    g.board[:f1,:a2] = 1
    
    11.times { g << g.moves.first }

    assert( !g.final? )

    g << g.moves.first

    assert( g.final? )
    assert( g.moves.empty? )
    assert_equal( 1, g.score( :one ) )
    assert_equal( 1, g.score( :two ) )
  end

  def test_final
    g = Game.new( rules )

    # Doctor the board

    g.board[:b1,:c1,:d1,:e1,:f1] = 0
    g.board[:b2,:c2,:d2,:e2,:f2] = 0

    assert( !g.final? )
    assert_equal( 0, g.score( :one ) )
    assert_equal( 0, g.score( :two ) )
    assert_equal( ['a1'], g.moves )

    g << :a1

    assert( !g.final? )  # :one's side is empty, but player two can still move

    g << :a2

    assert( g.final? )
    assert_equal( 0, g.score( :one ) )
    assert_equal( 8, g.score( :two ) )
    assert( !g.winner?( :one ) )
    assert( g.winner?( :two ) )
    assert( g.loser?( :one ) )
    assert( !g.loser?( :two ) )
    assert( !g.draw? )
  end

end

