require 'test/unit'

require 'vying'
require 'vying/rules/rules_test'

if Vying.random_support?

  class TestPig < Test::Unit::TestCase
    include RulesTests

    def rules
      Pig
    end

    def test_info
      assert_equal( "Pig", rules.name )
    end

    def test_players
      assert_equal( [:a,:b], rules.new.players )
    end

    def test_initialize
      g = Game.new( rules )
      assert_equal( Hash.new( 0 ), g.total )
      assert_equal( :a, g.turn )
      assert_equal( {:a => [], :b => []}, g.roll_history )
    end

    def test_has_moves
      g = Game.new( rules, 1234 )
      assert_equal( [:a], g.has_moves )
      g << :roll
      assert_equal( [:a], g.has_moves )
      g << :pass
      assert_equal( [:b], g.has_moves )
    end

    def test_moves
      g = Game.new( rules )
      moves = g.moves

      assert_equal( ['pass','roll'], moves )

      g << [:roll, :roll, :roll, :pass] until g.final?

      assert_not_equal( g.history[0], g.history.last )
    end

    def test_current_score
      g = Game.new( rules, 1234 )

      g << [:roll, :roll, :roll]
      assert_equal( 14, g.current_score )
      assert_equal( [[4, 4, 6]], g.roll_history[:a] )
      assert_equal( 0, g.score( :a ) )

      g << :pass
      assert_equal( 0, g.current_score )
      assert_equal( 14, g.score( :a ) )

      g << [:roll]
      assert_equal( 6, g.current_score )
      assert_equal( [[6]], g.roll_history[:b] )
      assert_equal( 0, g.score( :b ) )

      g << [:pass, :roll]
      assert_equal( 5, g.current_score )
      assert_equal( [[4, 4, 6], [5]], g.roll_history[:a] )
      assert_equal( 14, g.score( :a ) )

      g << [:roll, :roll]
      assert_equal( 0, g.current_score )
      assert_equal( [[4, 4, 6], [5, 5, 1]], g.roll_history[:a] )
      assert_equal( 14, g.score( :a ) )
    end

    def test_game
      g = Game.new( rules )

      srand 12345678
      g << g.moves[rand( g.moves.length )] until g.final?

      assert( !g.draw? )
  
      g.players.each do |p|
        assert( g.score( p ) >= 100 ) if g.winner?( p )
        assert( g.score( p )  < 100 ) if g.loser?( p )
      end
  
      assert( g.player_names.select { |p| g.winner?( p ) }.length == 1 )
      assert( g.player_names.select { |p| g.loser?(  p ) }.length == 1 )
    end
  end

end

