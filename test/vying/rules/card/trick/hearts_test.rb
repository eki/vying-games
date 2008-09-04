require 'test/unit'

require 'vying'
require 'vying/rules/rules_test'

if Vying.random_support?

  class TestHearts < Test::Unit::TestCase
    include RulesTests

    def rules
      Hearts
    end

    def test_info
      assert_equal( "Hearts", rules.name )
    end

    def test_players
      assert_equal( [:n,:e,:s,:w], rules.new.players )
    end

    def test_initialize       # Need to be more thorough here
      g = Game.new( rules )

      # Passing, so everyone has moves
      assert( g.has_moves.include?( :n ) )
      assert( g.has_moves.include?( :e ) )
      assert( g.has_moves.include?( :w ) )
      assert( g.has_moves.include?( :s ) )

      # Skip past passing phase
      12.times { g << g.moves.first }

      # The 2 of Clubs is led
      assert_equal( ['C2'], g.moves )
    end

    def test_has_moves
    end

    def test_moves
      g = Game.new( rules )
      assert( g.moves.include?( 'C2' ) )
      assert( g.move?( Card[:C2] ) )
      assert( g.move?( :C2 ) )
    end

    def test_shoot_moon
      g = Game.new( rules, 7319 )

      until g.pass_before_deal[:directions].first == :no_pass
        g.rotate_pass_before_deal
      end

      g.rotate_turn until g.hands[g.turn].include?( Card[:C2] )

      g <<  [:C2, :C7, :CA, :CQ, :SA, :S4, :S2, :S3, :S7, :ST, :SK, :S8,
             :SJ, :SQ, :S6, :S9, :D2, :DQ, :D8, :DA, :DJ, :D3, :DT, :D4,
             :D6, :D9, :D7, :HK, :DK, :HQ, :H9, :HJ, :D5, :HT, :H3, :H6, 
             :HA, :H7, :C9, :H5, :H8, :H2, :C6, :CJ, :H4, :CT, :C5, :C4,
             :CK, :C8, :C3]

      assert_equal( 0, g.score( :n ) )
      assert_equal( 0, g.score( :s ) )
      assert_equal( 0, g.score( :e ) )
      assert_equal( 0, g.score( :w ) )

      g << :S5

      assert_equal( 26, g.score( :n ) )
      assert_equal( 26, g.score( :s ) )
      assert_equal( 0, g.score( :e ) )
      assert_equal( 26, g.score( :w ) )
    end
  end

end

